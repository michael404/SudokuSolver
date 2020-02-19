extension SudokuBoard {
    
    func findFirstSolution() -> SudokuBoard? {
        findFirstSolution(using: WyRand())
    }
    
    func findFirstSolution<R: RNG>(using rng: R) -> SudokuBoard? {
        do {
            var solver = try SudokuSolver(eliminating: self, rng: rng)
            let solutions = try solver.solve(transformation: Normal.self, maxSolutions: 1)
            guard let solution = solutions.first else {throw SudokuSolverError.unsolvable }
            return solution
        } catch {
            return nil
        }
    }
    
    func findAllSolutions() -> [SudokuBoard] {
        findAllSolutions(using: WyRand())
    }
    
    func findAllSolutions<R: RNG>(using rng: R) -> [SudokuBoard] {
        do {
            var solver = try SudokuSolver(eliminating: self, rng: rng)
            let solutions = try solver.solve(transformation: Normal.self, maxSolutions: Int.max)
            assert(!solutions.isEmpty)
            return solutions
        } catch {
            return []
        }
    }
    
    static func randomFullyFilledBoard() -> SudokuBoard {
        return randomFullyFilledBoard(using: WyRand())
    }
    
    static func randomFullyFilledBoard<R: RNG>(using rng: R) -> SudokuBoard {
        do {
            var solver = try SudokuSolver(eliminating: SudokuBoard.empty, rng: rng)
            return try solver.solve(transformation: Shuffle.self, maxSolutions: 1).first!
        } catch {
            fatalError("Inconsistent state")
        }
    }
    
    enum NumberOfSolutions { case none, one, multiple }
    
    func numberOfSolutions() -> NumberOfSolutions {
        numberOfSolutions(using: WyRand())
    }
    
    func numberOfSolutions<R: RNG>(using rng: R) -> NumberOfSolutions {
        do {
            var solver = try SudokuSolver(eliminating: self, rng: rng)
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
        for (index, cell) in zip(self.board.indices, self.board) where cell.isSolved {
            try eliminatePossibilitites(basedOnSolvedIndex: index)
        }
    }
    
    mutating func solve<T: SudokuCellTransformation>(transformation: T.Type, maxSolutions: Int) throws -> [Board]
        where T.SudokuType == SudokuType, T.CellSequence.Element == Cell {
        var solutions: [Board] = []
        try guessAndEliminate(transformation: transformation, maxSolutions: maxSolutions, solutions: &solutions)
        return solutions
    }
    
    /// Throws if we are in an impossible situation
    private mutating func eliminatePossibilitites(basedOnSolvedIndex index: Int) throws {
        assert(board[index].isSolved)
        for indexToRemoveFrom in SudokuType.constants.indiciesAffectedByIndex(index) {
            try removeAndApplyConstraints(valueToRemove: board[index], indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
    private mutating func removeAndApplyConstraints(valueToRemove: Cell, indexToRemoveFrom: Int) throws {
        if try board[indexToRemoveFrom].remove(valueToRemove) {
            switch board[indexToRemoveFrom].count {
            case 1: try eliminatePossibilitites(basedOnSolvedIndex: indexToRemoveFrom)
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
        
        //TODO: Should all passes go here?
        try self.findAllHiddenPairs()
        
        guard let index = self.unsolvedIndexWithMostConstraints() else {
            solutions.append(self.board)
            return
        }
        for guess in T.transform(board[index], rng: &rng) {
            do {
                var newSolver = self
                newSolver.board[index] = guess
                try newSolver.eliminatePossibilitites(basedOnSolvedIndex: index)
                // While it would make sense to check for hidden singles only in rows/columns/boxes where a
                // possibility has just been removed, benchmarking shows that it is more efficient to run this
                // once per guess for the whole board. In theory this could also be run in a loop until there
                // are no more changes, but that does not improve performance either.
                try newSolver.findAllHiddenSingles()
//                try newSolver.findAllHiddenPairs()
                try newSolver.guessAndEliminate(
                    transformation: transformation,
                    maxSolutions: maxSolutions,
                    solutions: &solutions)
                if solutions.count >= maxSolutions { return }
            } catch {
                try self.removeAndApplyConstraints(valueToRemove: guess, indexToRemoveFrom: index)
            }
        }
    }
    
    private mutating func findAllHiddenSingles() throws {
        for unit in SudokuType.allPossibilities {
            try _findHiddenSingles(for: SudokuType.constants.allIndiciesInRow(unit))
            try _findHiddenSingles(for: SudokuType.constants.allIndiciesInColumn(unit))
            try _findHiddenSingles(for: SudokuType.constants.allIndiciesInBox(unit))
        }
    }

    private mutating func _findHiddenSingles(for indicies: UnsafeBufferPointer<Int>) throws {
        cellValueLoop: for cellValue in Cell.allTrue {
            var potentialFoundIndex: Int?
            for index in indicies where board[index].contains(cellValue) {
                // If we have already found one value in this unit, it is not a candiadate for a hidden single
                guard potentialFoundIndex == nil else { continue cellValueLoop }
                // If we have found a solved value, that is not a candidate for a hidden single
                guard !board[index].isSolved else { continue cellValueLoop }
                potentialFoundIndex = index
            }
            // If we did not find the value at all, the board is unsolvable
            guard let foundIndex = potentialFoundIndex else { throw SudokuSolverError.unsolvable }
            // We have identified a hidden single, and can set the cell to that value
            board[foundIndex] = cellValue
            try eliminatePossibilitites(basedOnSolvedIndex: foundIndex)
        }
    }
    
    private mutating func findAllHiddenPairs() throws {
        for unit in SudokuType.allPossibilities {
            try _findHiddenPairs(for: SudokuType.constants.allIndiciesInRow(unit))
            try _findHiddenPairs(for: SudokuType.constants.allIndiciesInColumn(unit))
            try _findHiddenPairs(for: SudokuType.constants.allIndiciesInBox(unit))
        }
    }

    private mutating func _findHiddenPairs(for indicies: UnsafeBufferPointer<Int>) throws {
        
        value1Loop: for value1 in Cell.allTrue {
            
            var (value1Index1, value1Index2): (Int?, Int?)
            
            for index in indicies where self.board[index].contains(value1) {
                guard  board[index].count != 2 else {
                    continue value1Loop
                }
                switch (value1Index1, value1Index2) {
                case (nil, _):
                    value1Index1 = index
                case (_?, nil):
                    value1Index2 = index
                case (_?, _?):
                    // Two matches already found
                    continue value1Loop
                }
            }
            guard case let (_value1Index1?, _value1Index2?) = (value1Index1, value1Index2) else {
                continue value1Loop
            }
                        
            value2Loop: for value2 in board[_value1Index1] where value1 != value2 {
                                
                if board[_value1Index2].contains(value2) {
                                        
                    // Make sure that value2 only exists at the two identified indicies
                    for index in indicies where index != _value1Index1 && index != _value1Index2 && self.board[index].contains(value2) {
                        continue value2Loop
                    }
                    
                    let isolatedValues = value1.combined(with: value2)
                    self.board[_value1Index1] = isolatedValues
                    self.board[_value1Index2] = isolatedValues
                    return //TODO: Should we continue loop1 instead?
                }
            }
        }
    }
    
    private mutating func eliminateNakedPairs(basedOnChangeOf index: Int) throws {
        let value = board[index]
        try _eliminateNakedPairs(value: value, for: SudokuType.constants.indiciesInSameRowExclusive(index))
        try _eliminateNakedPairs(value: value, for: SudokuType.constants.indiciesInSameColumnExclusive(index))
        try _eliminateNakedPairs(value: value, for: SudokuType.constants.indiciesInSameBoxExclusive(index))
    }

    private mutating func _eliminateNakedPairs(value: Cell, for indicies: UnsafeBufferPointer<Int>) throws {
        assert(value.count == 2)
        guard let cellWithSameTwoValues = indicies.first(where: { board[$0] == value }) else { return }
        // Found a duplicate. Loop over all indicies, exept the current one and remove from that
        for indexToRemoveFrom in indicies where indexToRemoveFrom != cellWithSameTwoValues {
            // If more than two cells only have the same two possibilities, this is unsolvable
            guard value != board[indexToRemoveFrom] else { throw SudokuSolverError.unsolvable }
            try removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
}
