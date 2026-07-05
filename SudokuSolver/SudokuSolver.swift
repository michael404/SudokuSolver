import Algorithms

extension SudokuBoard {
    
    func findFirstSolution() -> SudokuBoard? {
        var rng = WyRand()
        return findFirstSolution(using: &rng)
    }
    
    func findFirstSolution<R: RNG>(using rng: inout R) -> SudokuBoard? {
        do {
            var solver = try SudokuSolver(eliminating: self, rng: rng)
            defer { rng = solver.rng }
            let solutions = try solver.solve(transformation: Normal.self, maxSolutions: 1)
            guard let solution = solutions.first else {throw SudokuSolverError.unsolvable }
            return solution
        } catch {
            return nil
        }
    }
    
    func findAllSolutions() -> [SudokuBoard] {
        var rng = WyRand()
        return findAllSolutions(using: &rng)
    }
    
    func findAllSolutions<R: RNG>(using rng: inout R) -> [SudokuBoard] {
        do {
            var solver = try SudokuSolver(eliminating: self, rng: rng)
            defer { rng = solver.rng }
            let solutions = try solver.solve(transformation: Normal.self, maxSolutions: Int.max)
            assert(!solutions.isEmpty)
            return solutions
        } catch {
            return []
        }
    }
    
    static func randomFullyFilledBoard() -> SudokuBoard {
        var rng = WyRand()
        return randomFullyFilledBoard(using: &rng)
    }
    
    static func randomFullyFilledBoard<R: RNG>(using rng: inout R) -> SudokuBoard {
        do {
            var solver = try SudokuSolver(eliminating: SudokuBoard.empty, rng: rng)
            defer { rng = solver.rng }
            return try solver.solve(transformation: Shuffle.self, maxSolutions: 1).first!
        } catch {
            fatalError("Inconsistent state")
        }
    }
    
    enum NumberOfSolutions { case none, one, multiple }
    
    func numberOfSolutions() -> NumberOfSolutions {
        var rng = WyRand()
        return numberOfSolutions(using: &rng)
    }
    
    func numberOfSolutions<R: RNG>(using rng: inout R) -> NumberOfSolutions {
        do {
            var solver = try SudokuSolver(eliminating: self, rng: rng)
            defer { rng = solver.rng }
            let solutions = try solver.solve(transformation: Normal.self, maxSolutions: 2)
            switch solutions.count {
            case 1: return .one
            case 2: return .multiple
            default: fatalError()
            }
        } catch {
            return .none
        }
    }
}

struct SudokuSolver<SudokuType: SudokuTypeProtocol, R: RNG> {
    
    typealias Board = SudokuBoard<SudokuType>
    typealias Cell = SudokuCell<SudokuType>
    var board: Board
    var rng: R
    
    init(eliminating board: Board, rng: R) throws {
        self.board = board
        self.rng = rng
        for (index, cell) in self.board.indexed() where cell.isSolved {
            try eliminatePossibilities(basedOnSolvedIndex: index)
        }
    }
    
    mutating func solve<T: SudokuCellTransformation>(transformation: T.Type, maxSolutions: Int) throws -> [Board]
        where T.SudokuType == SudokuType, T.CellSequence.Element == Cell {
        var solutions: [Board] = []
        try guessAndEliminate(transformation: transformation, maxSolutions: maxSolutions, solutions: &solutions)
        return solutions
    }
    
    /// Throws if we are in an impossible situation
    private mutating func eliminatePossibilities(basedOnSolvedIndex index: Int) throws {
        assert(board[index].isSolved)
        for indexToRemoveFrom in SudokuType.constants.indicesAffectedByIndex(index) {
            try removeAndApplyConstraints(valueToRemove: board[index], indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
    private mutating func removeAndApplyConstraints(valueToRemove: Cell, indexToRemoveFrom: Int) throws {
        if try board[indexToRemoveFrom].remove(valueToRemove) {
            switch board[indexToRemoveFrom].count {
            case 1: try eliminatePossibilities(basedOnSolvedIndex: indexToRemoveFrom)
            case 2: try eliminateNakedPairs(basedOnChangeOf: indexToRemoveFrom)
            default: break
            }
        }
    }
    
    private mutating func unsolvedIndexWithMostConstraints() -> Board.Index? {
        for possibleValues in 2...SudokuType.possibilities {
            if let index = board.indices.randomElement(using: &self.rng, where: { board[$0].count == possibleValues }) {
                return index
            }
        }
        return nil
    }
    
    private mutating func guessAndEliminate<T: SudokuCellTransformation>(
        transformation: T.Type,
        maxSolutions: Int,
        solutions: inout [Board]
    ) throws where T.SudokuType == SudokuType, T.CellSequence.Element == Cell {
        guard let index = self.unsolvedIndexWithMostConstraints() else {
            solutions.append(self.board)
            return
        }
        for guess in T.transform(board[index], rng: &rng) {
            var newSolver = self
            do {
                newSolver.board[index] = guess
                try newSolver.eliminatePossibilities(basedOnSolvedIndex: index)
                // While it would make sense to check for hidden singles only in rows/columns/boxes where a
                // possibility has just been removed, benchmarking shows that it is more efficient to run this
                // once per guess for the whole board. In theory this could also be run in a loop until there
                // are no more changes, but that does not improve performance either.
                try newSolver.findAllHiddenSingles()
                try newSolver.guessAndEliminate(
                    transformation: transformation,
                    maxSolutions: maxSolutions,
                    solutions: &solutions)
                self.rng = newSolver.rng
                if solutions.count >= maxSolutions { return }
            } catch {
                self.rng = newSolver.rng
                try self.removeAndApplyConstraints(valueToRemove: guess, indexToRemoveFrom: index)
            }
        }
    }
    
    private mutating func findAllHiddenSingles() throws {
        for unit in SudokuType.allPossibilities {
            try _findHiddenSingles(for: SudokuType.constants.allIndicesInRow(unit))
            try _findHiddenSingles(for: SudokuType.constants.allIndicesInColumn(unit))
            try _findHiddenSingles(for: SudokuType.constants.allIndicesInBox(unit))
        }
    }

    private mutating func _findHiddenSingles(for indices: UnsafeBufferPointer<Int>) throws {
        cellValueLoop: for cellValue in Cell.allTrue {
            guard let firstIndex = indices.first(where: { board[$0].contains(cellValue) }) else {
                // If we cannot find a cell value at all in a unit, then this Sudoku is unsolvable
                throw SudokuSolverError.unsolvable
            }
            // If the value we found is already in a solved cell, then there is no point of continuing
            guard !board[firstIndex].isSolved else { continue cellValueLoop }
            // Force unwrap here is safe because we know that there exists a value already
            let lastIndex = indices.last { board[$0].contains(cellValue) }!
            if firstIndex == lastIndex {
                board[firstIndex] = cellValue
                try eliminatePossibilities(basedOnSolvedIndex: firstIndex)
            }
        }
    }
    
    private mutating func eliminateNakedPairs(basedOnChangeOf index: Int) throws {
        let value = board[index]
        try _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameRowExclusive(index))
        try _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameColumnExclusive(index))
        try _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameBoxExclusive(index))
    }

    private mutating func _eliminateNakedPairs(value: Cell, for indices: UnsafeBufferPointer<Int>) throws {
        assert(value.count == 2)
        guard let cellWithSameTwoValues = indices.first(where: { board[$0] == value }) else { return }
        // Found a duplicate. Loop over all indices, except the current one and remove from that
        for indexToRemoveFrom in indices where indexToRemoveFrom != cellWithSameTwoValues {
            // If more than two cells only have the same two possibilities, this is unsolvable
            guard value != board[indexToRemoveFrom] else { throw SudokuSolverError.unsolvable }
            try removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
}
