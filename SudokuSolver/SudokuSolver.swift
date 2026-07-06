import Algorithms

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
        for (index, cell) in self.board.indexed() where cell.isSolved {
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
        assert(board[index].isSolved)
        for indexToRemoveFrom in SudokuType.constants.indicesAffectedByIndex(index) {
            guard removeAndApplyConstraints(valueToRemove: board[index], indexToRemoveFrom: indexToRemoveFrom) else {
                return false
            }
        }
        return true
    }
    
    private mutating func removeAndApplyConstraints(valueToRemove: Cell, indexToRemoveFrom: Int) -> Bool {
        guard let didRemove = board[indexToRemoveFrom].removeIfPossible(valueToRemove) else { return false }
        if didRemove {
            switch board[indexToRemoveFrom].count {
            case 1: return eliminatePossibilities(basedOnSolvedIndex: indexToRemoveFrom)
            case 2: return eliminateNakedPairs(basedOnChangeOf: indexToRemoveFrom)
            default: break
            }
        }
        return true
    }
    
    private mutating func unsolvedIndexWithMostConstraints() -> Board.Index? {
        var result: Board.Index?
        var bestCount = Int.max
        var tiedBestCount = 0
        
        for index in board.indices {
            let count = board[index].count
            guard count > 1 else { continue }
            
            if count < bestCount {
                bestCount = count
                result = index
                tiedBestCount = 1
            } else if count == bestCount {
                tiedBestCount += 1
                if Int.random(in: 0..<tiedBestCount, using: &rng) == 0 {
                    result = index
                }
            }
        }
        return result
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
        for guess in T.transform(board[index], rng: &rng) {
            var newSolver = self
            newSolver.board[index] = guess
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
        cellValueLoop: for cellValue in Cell.allTrue {
            var hiddenSingleIndex: Int?
            
            for index in indices {
                let cell = board[index]
                guard cell.contains(cellValue) else { continue }
                guard !cell.isSolved else { continue cellValueLoop }
                guard hiddenSingleIndex == nil else { continue cellValueLoop }
                hiddenSingleIndex = index
            }
            
            guard let hiddenSingleIndex else {
                // If we cannot find a cell value at all in a unit, then this Sudoku is unsolvable
                return false
            }
            board[hiddenSingleIndex] = cellValue
            guard eliminatePossibilities(basedOnSolvedIndex: hiddenSingleIndex) else { return false }
        }
        return true
    }
    
    private mutating func eliminateNakedPairs(basedOnChangeOf index: Int) -> Bool {
        let value = board[index]
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
        guard let cellWithSameTwoValues = indices.first(where: { board[$0] == value }) else { return true }
        // Found a duplicate. Loop over all indices, except the current one and remove from that
        for indexToRemoveFrom in indices where indexToRemoveFrom != cellWithSameTwoValues {
            // If more than two cells only have the same two possibilities, this is unsolvable
            guard value != board[indexToRemoveFrom] else { return false }
            guard removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: indexToRemoveFrom) else {
                return false
            }
        }
        return true
    }
    
}
