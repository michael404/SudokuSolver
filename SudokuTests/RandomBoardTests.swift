import XCTest

class RandomBoardTests: XCTestCase {

    // MARK: - Minimizer properties (9x9)

    /// The minimizer's greedy algorithm guarantees provable properties beyond
    /// "has a unique solution"; pin them down.
    func testMinimizerProperties() {
        var rng = WyRand(seed: 1)
        let filled = SudokuBoard9.randomFullyFilledBoard(using: &rng)
        let minimized = filled.minimizingClues(using: &rng)

        XCTAssertFalse(minimized.isFullyFilled)

        // Every remaining clue is one of the input clues, with its value unchanged.
        for index in minimized.indices where minimized[index].isSolved {
            XCTAssertEqual(minimized[index], filled[index], "Clue at \(index) changed value")
        }

        // The minimized board has exactly the original board as its solution.
        XCTAssertEqual(minimized.findAllSolutions(), [filled])

        // 1-minimality: every remaining clue is load-bearing. This follows from
        // the greedy algorithm, because removing clues can only grow the solution
        // set: a clue that was kept because its removal broke uniqueness cannot
        // become removable after further removals.
        var board = minimized
        for index in board.indices where board[index].isSolved {
            let clue = board[index]
            board[index] = .allTrue
            XCTAssertEqual(board.numberOfSolutions(), .multiple, "Clue at \(index) was removable")
            board[index] = clue
        }
    }

    func testMinimizerIsIdempotent() {
        var rng = WyRand(seed: 2)
        let minimized = SudokuBoard9.randomStartingBoard(rng: &rng)
        // A 1-minimal board has no removable clue, regardless of removal order.
        let again = minimized.minimizingClues(using: &rng)
        XCTAssertEqual(again, minimized)
    }

    func testGenerationIsDeterministicPerSeed() {
        var rng1 = WyRand(seed: 3)
        var rng2 = WyRand(seed: 3)
        var rng3 = WyRand(seed: 4)
        let board1 = SudokuBoard9.randomStartingBoard(rng: &rng1)
        let board2 = SudokuBoard9.randomStartingBoard(rng: &rng2)
        let board3 = SudokuBoard9.randomStartingBoard(rng: &rng3)
        XCTAssertEqual(board1, board2)
        XCTAssertNotEqual(board1, board3)
    }

    // MARK: - 16x16

    func testRandomFullyFilledBoard16() {
        var rng = WyRand(seed: 16)
        let board = SudokuBoard16.randomFullyFilledBoard(using: &rng)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 256)
        XCTAssertTrue(board.hasUniqueSolution)
        XCTAssertEqual(board.findFirstSolution(), board)
    }

    func testRandomStartingBoard16() {
        var rng = WyRand(seed: 17)
        let board = SudokuBoard16.randomStartingBoard(rng: &rng)
        XCTAssertEqual(board.numberOfSolutions(), .one)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((70...120).contains(board.clues), "Unexpected clue count: \(board.clues)")
    }

    func testMinimizerProperties16() {
        var rng = WyRand(seed: 18)
        let filled = SudokuBoard16.randomFullyFilledBoard(using: &rng)
        let minimized = filled.minimizingClues(using: &rng)

        for index in minimized.indices where minimized[index].isSolved {
            XCTAssertEqual(minimized[index], filled[index], "Clue at \(index) changed value")
        }
        XCTAssertEqual(minimized.findAllSolutions(), [filled])

        var board = minimized
        for index in board.indices where board[index].isSolved {
            let clue = board[index]
            board[index] = .allTrue
            XCTAssertEqual(board.numberOfSolutions(), .multiple, "Clue at \(index) was removable")
            board[index] = clue
        }
    }

    // MARK: - Parallel minimizer

    func testParallelMinimizerProperties() {
        var rng = WyRand(seed: 7)
        let filled = SudokuBoard9.randomFullyFilledBoard(using: &rng)
        let minimized = filled.minimizingCluesParallel(using: &rng)

        XCTAssertFalse(minimized.isFullyFilled)
        for index in minimized.indices where minimized[index].isSolved {
            XCTAssertEqual(minimized[index], filled[index], "Clue at \(index) changed value")
        }
        XCTAssertEqual(minimized.findAllSolutions(), [filled])

        // The screen-then-confirm split preserves 1-minimality with an unlimited budget.
        var board = minimized
        for index in board.indices where board[index].isSolved {
            let clue = board[index]
            board[index] = .allTrue
            XCTAssertEqual(board.numberOfSolutions(), .multiple, "Clue at \(index) was removable")
            board[index] = clue
        }
    }

    func testParallelMinimizerIsDeterministic() {
        var rng1 = WyRand(seed: 8)
        var rng2 = WyRand(seed: 8)
        let filled1 = SudokuBoard16.randomFullyFilledBoard(using: &rng1)
        let filled2 = SudokuBoard16.randomFullyFilledBoard(using: &rng2)
        XCTAssertEqual(filled1, filled2)
        XCTAssertEqual(
            filled1.minimizingCluesParallel(using: &rng1),
            filled2.minimizingCluesParallel(using: &rng2))
    }

    func testParallelMinimizerWithNodeLimit() {
        var rng = WyRand(seed: 9)
        let filled = SudokuBoard9.randomFullyFilledBoard(using: &rng)
        let limited = filled.minimizingCluesParallel(using: &rng, nodeLimit: 0)
        XCTAssertEqual(limited.findAllSolutions(), [filled])
        for index in limited.indices where limited[index].isSolved {
            XCTAssertEqual(limited[index], filled[index], "Clue at \(index) changed value")
        }
    }

    // MARK: - Node-limited search

    func testNodeLimitedSearch() {
        // hard1 cannot be completed by init-time propagation alone, so a zero
        // guess budget cannot decide it either way.
        var rng = WyRand(seed: 5)
        XCTAssertEqual(TestData9.hard1.board.numberOfSolutions(using: &rng, nodeLimit: 0), .unknown)
        XCTAssertEqual(TestData9.hard1.board.findFirstSolution(using: &rng, nodeLimit: 0), .indeterminate)

        // With an unlimited budget the same calls decide as before.
        XCTAssertEqual(TestData9.hard1.board.numberOfSolutions(using: &rng), .one)
        XCTAssertEqual(
            TestData9.hard1.board.findFirstSolution(using: &rng, nodeLimit: .max),
            .solution(TestData9.hard1.solution))

        // Boards decidable without guessing are unaffected by a zero budget.
        XCTAssertEqual(TestData9.filled.numberOfSolutions(using: &rng, nodeLimit: 0), .one)
        XCTAssertEqual(TestData9.filled.findFirstSolution(using: &rng, nodeLimit: 0), .solution(TestData9.filled))
        XCTAssertEqual(TestData9.invalid.findFirstSolution(using: &rng, nodeLimit: 0), .unsolvable)
    }

    func testMinimizerWithNodeLimit() {
        var rng = WyRand(seed: 6)
        let filled = SudokuBoard9.randomFullyFilledBoard(using: &rng)
        let limited = filled.minimizingClues(using: &rng, nodeLimit: 0)

        // A budget-limited minimization keeps every clue whose check could not
        // complete, but still only removes clues and preserves the unique solution.
        XCTAssertEqual(limited.findAllSolutions(), [filled])
        for index in limited.indices where limited[index].isSolved {
            XCTAssertEqual(limited[index], filled[index], "Clue at \(index) changed value")
        }

        // Unbounded minimization of the same board removes at least as many clues.
        var rng2 = WyRand(seed: 6)
        let sameFilled = SudokuBoard9.randomFullyFilledBoard(using: &rng2)
        XCTAssertEqual(sameFilled, filled)
        let unbounded = sameFilled.minimizingClues(using: &rng2)
        XCTAssertLessThanOrEqual(unbounded.clues, limited.clues)
    }

    // MARK: - 4x4

    func testRandomStartingBoard4() {
        var rng = WyRand(seed: 4)
        let board = SudokuBoard4.randomStartingBoard(rng: &rng)
        XCTAssertEqual(board.numberOfSolutions(), .one)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((1...15).contains(board.clues), "Unexpected clue count: \(board.clues)")
    }

}
