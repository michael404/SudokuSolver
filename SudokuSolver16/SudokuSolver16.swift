extension SudokuBoard16 {
    
    func findFirstSolution() throws -> SudokuBoard16 {
        try findFirstSolution(using: Xoroshiro())
    }
    
    func findFirstSolution<R: RNG>(using rng: R) throws -> SudokuBoard16 {
        var solver = try SudokuSolver16(eliminating: self, rng: rng)
        return try solver.guessAndEliminate(transformation: Normal16.self)
    }
    
    static func randomFullyFilledBoard() -> SudokuBoard16 {
        return randomFullyFilledBoard(using: Xoroshiro())
    }
    
    static func randomFullyFilledBoard<R: RNG>(using rng: R) -> SudokuBoard16 {
        var solver = try! SudokuSolver16(eliminating: SudokuBoard16.empty, rng: rng)
        return try! solver.guessAndEliminate(transformation: Shuffle16.self)
    }
    
    enum NumberOfSolutions {
        case none
        case one
        case multiple
    }
    
    func numberOfSolutions() -> NumberOfSolutions {
        numberOfSolutions(using: Xoroshiro())
    }
    
    func numberOfSolutions<R: RNG>(using rng: R) -> NumberOfSolutions {
        do {
            var solver1 = try SudokuSolver16(eliminating: self, rng: rng)
            var solver2 = solver1 // No need to recompute the inital elimination
            
            // This does not seem to benefit by being run in paralell, potentially because that
            // eliminates the possibility to exit early by throwing if the board is unsolvable
            let firstSolution = try solver1.guessAndEliminate(transformation: Normal16.self)
            let lastSolution = try solver2.guessAndEliminate(transformation: Reverse16.self)
            
            return firstSolution == lastSolution ? .one : .multiple
        } catch {
            return .none
        }
    }
}

struct SudokuSolver16<R: RNG> {
    
    var board: SudokuBoard16
    var rng: R
    
    init(eliminating board: SudokuBoard16, rng: R) throws {
        self.board = board
        self.rng = rng
        for (index, cell) in zip(self.board.indices, self.board) where cell.isSolved {
            try eliminatePossibilitites(basedOnSolvedIndex: index)
        }
    }
    
    /// Throws if we are in an impossible situation
    mutating func eliminatePossibilitites(basedOnSolvedIndex index: Int) throws {
        assert(board[index].isSolved)
        for indexToRemoveFrom in Constants16.indiciesAffected(by: index) {
            try removeAndApplyConstraints(valueToRemove: board[index], indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
    mutating func removeAndApplyConstraints(valueToRemove: SudokuCell16, indexToRemoveFrom: Int) throws {
        if try board[indexToRemoveFrom].remove(valueToRemove) {
            switch board[indexToRemoveFrom].count {
            case 1: try eliminatePossibilitites(basedOnSolvedIndex: indexToRemoveFrom)
            case 2: try eliminateNakedPairs(basedOnChangeOf: indexToRemoveFrom)
            default: break
            }
        }
    }
    
    mutating func unsolvedIndexWithMostConstraints() -> SudokuBoard16.Index? {
        for possibleValues in 2...16 {
            let board = self.board
            if let index = self.board.indices.lazy.filter({ board[$0].count == possibleValues }).randomElement(using: &self.rng) {
                return index
            }
        }
        return nil
    }
    
    mutating func guessAndEliminate<T: SudokuCell16Transformation>(transformation: T.Type) throws -> SudokuBoard16 {
        guard let index = self.unsolvedIndexWithMostConstraints() else { return board }
        for guess in T.transform(board[index], rng: &rng) {
            do {
                var newSolver = self
                newSolver.board[index] = guess
                try newSolver.eliminatePossibilitites(basedOnSolvedIndex: index)
                // While it would make sense to check for hidden singles only in rows/columns/boxes where a possibility
                // has just been removed, benchmarking shows that it is more efficient to run this once per guess for the
                // whole board. In theory this could also be run in a loop until there are no more changes, but that does
                // not improve performance either.
                try newSolver.findAllHiddenSingles()
                return try newSolver.guessAndEliminate(transformation: transformation)
            } catch {
                try self.removeAndApplyConstraints(valueToRemove: guess, indexToRemoveFrom: index)
            }
        }
        // Only fail and throw if we have tried all possible values for the current cell and all of those
        // branches failed and throwed.
        throw SudokuSolverError.unsolvable
    }
    
    mutating func findAllHiddenSingles() throws {
        for unit in 0..<16 {
            try _findHiddenSingles(for: Constants16.allIndiciesInRow(number: unit))
            try _findHiddenSingles(for: Constants16.allIndiciesInColumn(number: unit))
            try _findHiddenSingles(for: Constants16.allIndiciesInBox(number: unit))
        }
    }

    mutating func _findHiddenSingles(for indicies: ArraySlice<Int>) throws {
        cellValueLoop: for cellValue in SudokuCell16.allTrue {
            var potentialFoundIndex: Int? = nil
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
    
    mutating func eliminateNakedPairs(basedOnChangeOf index: Int) throws {
        let value = board[index]
        try _eliminateNakedPairs(value: value, for: Constants16.indiciesInSameRow(as: index))
        try _eliminateNakedPairs(value: value, for: Constants16.indiciesInSameColumn(as: index))
        try _eliminateNakedPairs(value: value, for: Constants16.indiciesInSameBox(as: index))
    }

    mutating func _eliminateNakedPairs(value: SudokuCell16, for indicies: ArraySlice<Int>) throws {
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
