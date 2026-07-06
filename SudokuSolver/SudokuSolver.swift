extension SudokuBoard {
    
    func findFirstSolution() -> SudokuBoard? {
        var rng = WyRand()
        return findFirstSolution(using: &rng)
    }
    
    func findFirstSolution<R: RNG>(using rng: inout R) -> SudokuBoard? {
        guard var solver = SudokuSolver(eliminating: self, rng: rng) else { return nil }
        defer { rng = solver.rng }
        let solutions = solver.solve(transformation: Normal.self, maxSolutions: 1)
        return solutions.first
    }
    
    func findAllSolutions() -> [SudokuBoard] {
        var rng = WyRand()
        return findAllSolutions(using: &rng)
    }
    
    func findAllSolutions<R: RNG>(using rng: inout R) -> [SudokuBoard] {
        guard var solver = SudokuSolver(eliminating: self, rng: rng) else { return [] }
        defer { rng = solver.rng }
        let solutions = solver.solve(transformation: Normal.self, maxSolutions: Int.max)
        return solutions
    }
    
    static func randomFullyFilledBoard() -> SudokuBoard {
        var rng = WyRand()
        return randomFullyFilledBoard(using: &rng)
    }
    
    static func randomFullyFilledBoard<R: RNG>(using rng: inout R) -> SudokuBoard {
        guard var solver = SudokuSolver(eliminating: SudokuBoard.empty, rng: rng) else {
            fatalError("Inconsistent state")
        }
        defer { rng = solver.rng }
        return solver.solve(transformation: Shuffle.self, maxSolutions: 1).first!
    }
    
    enum NumberOfSolutions { case none, one, multiple }
    
    func numberOfSolutions() -> NumberOfSolutions {
        var rng = WyRand()
        return numberOfSolutions(using: &rng)
    }
    
    func numberOfSolutions<R: RNG>(using rng: inout R) -> NumberOfSolutions {
        guard var solver = SudokuSolver(eliminating: self, rng: rng) else { return .none }
        defer { rng = solver.rng }
        let solutions = solver.solve(transformation: Normal.self, maxSolutions: 2)
        switch solutions.count {
        case 0: return .none
        case 1: return .one
        default: return .multiple
        }
    }
}

struct SudokuSolver<SudokuType: SudokuTypeProtocol, R: RNG> {
    
    typealias Board = SudokuBoard<SudokuType>
    typealias Cell = SudokuCell<SudokuType>
    var board: Board
    var rng: R
    
    init?(eliminating board: Board, rng: R) {
        self.board = board
        self.rng = rng
        // Iterates the unmodified `board` parameter so that only the originally
        // solved cells trigger elimination, as cascades solve more cells as we go.
        for index in SudokuType.allCells where board[index].isSolved {
            guard eliminatePossibilities(basedOnSolvedIndex: index) else { return nil }
        }
    }
    
    mutating func solve<T: SudokuCellTransformation>(transformation: T.Type, maxSolutions: Int) -> [Board]
        where T.SudokuType == SudokuType, T.CellSequence.Element == Cell {
        var solutions: [Board] = []
        _ = guessAndEliminate(transformation: transformation, maxSolutions: maxSolutions, solutions: &solutions)
        return solutions
    }
    
    /// Returns false if we are in an impossible situation.
    private mutating func eliminatePossibilities(basedOnSolvedIndex index: Int) -> Bool {
        assert(board.cell(at: index).isSolved)
        for indexToRemoveFrom in SudokuType.constants.indicesAffectedByIndex(index) {
            let valueToRemove = board.cell(at: index)
            guard removeAndApplyConstraints(valueToRemove: valueToRemove, indexToRemoveFrom: indexToRemoveFrom) else {
                return false
            }
        }
        return true
    }

    private mutating func removeAndApplyConstraints(valueToRemove: Cell, indexToRemoveFrom: Int) -> Bool {
        var cell = board.cell(at: indexToRemoveFrom)
        guard let didRemove = cell.removeIfPossible(valueToRemove) else { return false }
        if didRemove {
            board.setCell(at: indexToRemoveFrom, to: cell)
            switch cell.count {
            case 1: return eliminatePossibilities(basedOnSolvedIndex: indexToRemoveFrom)
            case 2: return eliminateNakedPairs(basedOnChangeOf: indexToRemoveFrom)
            default: break
            }
        }
        return true
    }
    
    private mutating func unsolvedIndexWithMostConstraints() -> Board.Index? {
        // Collect all cells tied for the fewest possibilities and pick one uniformly
        // with a single RNG draw, instead of reservoir sampling with one draw per tie.
        withUnsafeTemporaryAllocation(of: Board.Index.self, capacity: SudokuType.cells) { tied in
            var bestCount = Int.max
            var tiedCount = 0

            for index in board.indices {
                let count = board.cell(at: index).count
                guard count > 1 else { continue }

                if count < bestCount {
                    bestCount = count
                    tied[0] = index
                    tiedCount = 1
                } else if count == bestCount {
                    tied[tiedCount] = index
                    tiedCount += 1
                }
            }

            guard tiedCount > 1 else { return tiedCount == 1 ? tied[0] : nil }
            return tied[Int.random(in: 0..<tiedCount, using: &rng)]
        }
    }
    
    private mutating func guessAndEliminate<T: SudokuCellTransformation>(
        transformation: T.Type,
        maxSolutions: Int,
        solutions: inout [Board]
    ) -> Bool where T.SudokuType == SudokuType, T.CellSequence.Element == Cell {
        guard let index = self.unsolvedIndexWithMostConstraints() else {
            solutions.append(self.board)
            return true
        }
        for guess in T.transform(board.cell(at: index), rng: &rng) {
            var newSolver = self
            newSolver.board.setCell(at: index, to: guess)
            // While it would make sense to check for hidden singles only in rows/columns/boxes where a
            // possibility has just been removed, benchmarking shows that it is more efficient to run this
            // once per guess for the whole board. In theory this could also be run in a loop until there
            // are no more changes, but that does not improve performance either.
            if newSolver.eliminatePossibilities(basedOnSolvedIndex: index)
                && newSolver.findAllHiddenSingles()
                && newSolver.guessAndEliminate(
                    transformation: transformation,
                    maxSolutions: maxSolutions,
                    solutions: &solutions) {
                self.rng = newSolver.rng
                if solutions.count >= maxSolutions { return true }
            } else {
                self.rng = newSolver.rng
                guard removeAndApplyConstraints(valueToRemove: guess, indexToRemoveFrom: index) else { return false }
            }
        }
        return true
    }
    
    private mutating func findAllHiddenSingles() -> Bool {
        for unit in SudokuType.allPossibilities {
            guard _findHiddenSingles(for: SudokuType.constants.allIndicesInRow(unit)) else { return false }
            guard _findHiddenSingles(for: SudokuType.constants.allIndicesInColumn(unit)) else { return false }
            guard _findHiddenSingles(for: SudokuType.constants.allIndicesInBox(unit)) else { return false }
        }
        return true
    }

    private mutating func _findHiddenSingles(for indices: UnsafeBufferPointer<Int>) -> Bool {
        // One pass over the unit, accumulating which values have been seen at least
        // once, seen more than once, and seen in an already solved cell. A value that
        // has exactly one possible cell, and is not already solved there, is a hidden single.
        var seenOnce: SudokuType.CellStorage = 0
        var seenTwice: SudokuType.CellStorage = 0
        var solved: SudokuType.CellStorage = 0
        for index in indices {
            let cell = board.cell(at: index)
            seenTwice |= seenOnce & cell.storage
            seenOnce |= cell.storage
            if cell.isSolved { solved |= cell.storage }
        }

        // If we cannot find a cell value at all in a unit, then this Sudoku is unsolvable
        guard seenOnce == SudokuType.allTrueCellStorage else { return false }

        var singles = seenOnce & ~seenTwice & ~solved
        while singles != 0 {
            let value = Cell(storage: singles & ~(singles &- 1))
            singles &= singles &- 1
            // Eliminations triggered by a previous hidden single can have changed the
            // unit, so re-find the cell and re-check that the value is still placeable.
            var found = false
            for index in indices where board.cell(at: index).contains(value) {
                found = true
                if !board.cell(at: index).isSolved {
                    board.setCell(at: index, to: value)
                    guard eliminatePossibilities(basedOnSolvedIndex: index) else { return false }
                }
                break
            }
            guard found else { return false }
        }
        return true
    }
    
    private mutating func eliminateNakedPairs(basedOnChangeOf index: Int) -> Bool {
        let value = board.cell(at: index)
        guard _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameRowExclusive(index)) else {
            return false
        }
        guard _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameColumnExclusive(index)) else {
            return false
        }
        return _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameBoxExclusive(index))
    }

    private mutating func _eliminateNakedPairs(value: Cell, for indices: UnsafeBufferPointer<Int>) -> Bool {
        assert(value.count == 2)
        var cellWithSameTwoValues: Int?
        for index in indices where board.cell(at: index) == value {
            cellWithSameTwoValues = index
            break
        }
        guard let cellWithSameTwoValues else { return true }
        // Found a duplicate. Loop over all indices, except the current one and remove from that
        for indexToRemoveFrom in indices where indexToRemoveFrom != cellWithSameTwoValues {
            // If more than two cells only have the same two possibilities, this is unsolvable
            guard value != board.cell(at: indexToRemoveFrom) else { return false }
            guard removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: indexToRemoveFrom) else {
                return false
            }
        }
        return true
    }
    
}
