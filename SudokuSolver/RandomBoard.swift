import Foundation

/// Hands out consecutive work indices to worker threads.
private final class WorkCursor: @unchecked Sendable {
    private let lock = NSLock()
    private var next = 0
    func take() -> Int {
        lock.lock()
        defer { lock.unlock() }
        let value = next
        next += 1
        return value
    }
}

/// Thread-safe accumulator for indices found by worker threads.
private final class LockedIndexSet: @unchecked Sendable {
    private let lock = NSLock()
    private var indices: Set<Int> = []
    func insert(_ index: Int) {
        lock.lock()
        indices.insert(index)
        lock.unlock()
    }
    func snapshot() -> Set<Int> {
        lock.lock()
        defer { lock.unlock() }
        return indices
    }
}

/// Runs `work(0..<iterations)` across enough worker threads to use every core.
/// `DispatchQueue.concurrentPerform` and the Swift concurrency pool cap worker
/// stacks at 512 KB, which the solver's recursion overflows on large boards (a
/// 36x36 solver frame is ~12 KB and refutation searches recurse hundreds of
/// frames deep), so this uses explicit threads with large stacks instead.
private func concurrentPerformWithLargeStacks(iterations: Int, work: @escaping @Sendable (Int) -> Void) {
    guard iterations > 0 else { return }
    let cursor = WorkCursor()
    let threadCount = max(1, min(iterations, ProcessInfo.processInfo.activeProcessorCount))
    let finished = DispatchGroup()
    for _ in 0..<threadCount {
        finished.enter()
        let thread = Thread {
            while true {
                let index = cursor.take()
                guard index < iterations else { break }
                work(index)
            }
            finished.leave()
        }
        thread.stackSize = 32 << 20
        thread.start()
    }
    finished.wait()
}

extension SudokuBoard {

    static func randomStartingBoard() -> SudokuBoard {
        var rng = WyRand()
        return randomStartingBoard(rng: &rng)
    }

    static func randomStartingBoard<R: RNG>(rng: inout R) -> SudokuBoard {
        randomFullyFilledBoard(using: &rng).minimizingClues(using: &rng)
    }

}

internal extension SudokuBoard {

    /// Returns a copy of this board with every removable clue cleared, visiting
    /// cells in a random order. A clue is only removed when doing so provably keeps
    /// the solution unique, so the result has exactly the same single solution as
    /// this board and its clues are a subset of this board's clues.
    ///
    /// With the default unlimited `nodeLimit` the result is also 1-minimal: no
    /// single remaining clue can be removed without losing uniqueness. A finite
    /// `nodeLimit` bounds each removal check and conservatively keeps any clue
    /// whose check runs out of budget, which keeps large-board minimization from
    /// searching indefinitely at the cost of possibly retaining removable clues.
    ///
    /// This board must have exactly one solution when called; a fully filled board
    /// trivially qualifies.
    func minimizingClues<R: RNG>(using rng: inout R, nodeLimit: Int = .max) -> SudokuBoard {
        assert({ var checkRng = rng
                 return numberOfSolutions(using: &checkRng) == .one }(),
               "minimizingClues requires a board with exactly one solution")
        var board = self
        for index in board.indices.shuffled(using: &rng) {
            // The board so far has a unique solution, so clearing this cell keeps the
            // solution unique iff no *other* value in this cell admits a solution.
            // Checking that directly is much cheaper than proving uniqueness from
            // scratch, which has to re-derive the known solution and then exhaust
            // the rest of the search space.
            let alternatives = board.alternativeValues(at: index)
            if alternatives != 0 {
                var testBoard = board
                testBoard[index] = Cell(storage: alternatives)
                // Keep the clue unless the check proves no alternative solution
                // exists; an indeterminate, budget-limited check keeps it too.
                guard testBoard.findFirstSolution(using: &rng, nodeLimit: nodeLimit) == .unsolvable else {
                    continue
                }
            }
            board[index] = .allTrue
        }
        return board
    }

    /// Parallel variant of `minimizingClues(using:nodeLimit:)` with the same
    /// guarantees. The removability checks — the expensive part — are screened
    /// concurrently on all cores against the unmodified board, and the typically
    /// few candidates that pass screening are then confirmed sequentially against
    /// the evolving board, because two individually removable clues are not
    /// always jointly removable. Clues proven load-bearing during screening stay
    /// load-bearing after removals (removing clues only adds solutions), so the
    /// screen-then-confirm split preserves the sequential algorithm's guarantees.
    ///
    /// `rng` is consumed once to derive deterministic per-check seeds: results
    /// are reproducible for a given rng state, but differ from the boards the
    /// sequential method produces.
    ///
    /// Worth it when checks are expensive and few clues are removable (deep
    /// minimization of hard, large boards). When most clues are removable — e.g.
    /// minimizing a freshly filled easy board — confirmation has to redo most of
    /// the work sequentially and the sequential method is faster.
    func minimizingCluesParallel<R: RNG>(using rng: inout R, nodeLimit: Int = .max) -> SudokuBoard {
        assert({ var checkRng = rng
                 return numberOfSolutions(using: &checkRng) == .one }(),
               "minimizingCluesParallel requires a board with exactly one solution")
        let masterSeed = rng.next()
        var orderRng = WyRand(seed: masterSeed)
        let base = self
        let solvedIndices = indices.filter { self[$0].isSolved }.shuffled(using: &orderRng)

        // Screen all clues in parallel against the frozen base board.
        let collector = LockedIndexSet()
        concurrentPerformWithLargeStacks(iterations: solvedIndices.count) { position in
            let index = solvedIndices[position]
            let alternatives = base.alternativeValues(at: index)
            let removable: Bool
            if alternatives == 0 {
                removable = true
            } else {
                var testBoard = base
                testBoard[index] = Cell(storage: alternatives)
                var checkRng = WyRand(seed: masterSeed &+ UInt64(index) &* 0x9E37_79B9_7F4A_7C15)
                removable = testBoard.findFirstSolution(using: &checkRng, nodeLimit: nodeLimit) == .unsolvable
            }
            if removable {
                collector.insert(index)
            }
        }
        let screenedRemovable = collector.snapshot()

        // Confirm the candidates one at a time against the evolving board: each
        // earlier removal can invalidate later candidates.
        var board = self
        var confirmRng = WyRand(seed: masterSeed ^ 0xC0FF_EE00_C0FF_EE00)
        for index in solvedIndices where screenedRemovable.contains(index) {
            let alternatives = board.alternativeValues(at: index)
            if alternatives != 0 {
                var testBoard = board
                testBoard[index] = Cell(storage: alternatives)
                guard testBoard.findFirstSolution(using: &confirmRng, nodeLimit: nodeLimit) == .unsolvable else {
                    continue
                }
            }
            board[index] = .allTrue
        }
        return board
    }

    /// Candidate values for this cell other than its current value that are not
    /// excluded by a solved peer. Zero means no other value could legally go here,
    /// so clearing the cell trivially preserves uniqueness.
    private func alternativeValues(at index: Int) -> SudokuType.CellStorage {
        var board = self
        let cellAtIndex = board.cell(at: index)
        var alternatives = SudokuType.allTrueCellStorage & ~cellAtIndex.storage
        for peer in SudokuType.constants.indicesAffectedByIndex(index) {
            let peerCell = board.cell(at: Int(peer))
            if peerCell.isSolved { alternatives &= ~peerCell.storage }
        }
        return alternatives
    }

}
