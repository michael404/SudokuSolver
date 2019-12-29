extension SudokuBoard {
    
    func findFirstSolution() throws -> SudokuBoard {
        try findFirstSolution(using: Xoroshiro())
    }
    
    func findFirstSolution<R: RNG>(using rng: R) throws -> SudokuBoard {
        var solver = try SudokuSolver(eliminating: self, rng: rng)
        return try solver.guessAndEliminate(transformation: Normal.self)
    }
    
    static func randomFullyFilledBoard() -> SudokuBoard {
        return randomFullyFilledBoard(using: Xoroshiro())
    }
    
    static func randomFullyFilledBoard<R: RNG>(using rng: R) -> SudokuBoard {
        var solver = try! SudokuSolver(eliminating: SudokuBoard.empty, rng: rng)
        return try! solver.guessAndEliminate(transformation: Shuffle.self)
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
            var solver1 = try SudokuSolver(eliminating: self, rng: rng)
            var solver2 = solver1 // No need to recompute the inital elimination
            
            //TODO: Can this be done in paralell?
            let firstSolution = try solver1.guessAndEliminate(transformation: Normal.self)
            let lastSolution = try solver2.guessAndEliminate(transformation: Reverse.self)
            
            return firstSolution == lastSolution ? .one : .multiple
        } catch {
            return .none
        }
    }
}

struct SudokuSolver<R: RNG> {
    
    var board: SudokuBoard
    var rng: R
    
    init(eliminating board: SudokuBoard, rng: R) throws {
        self.board = board
        self.rng = rng
        for (index, cell) in zip(self.board.indices, self.board) where cell.isSolved {
            try eliminatePossibilitites(basedOnChangeOf: index)
        }
    }
    
    /// Throws if we are in an impossible situation
    mutating func eliminatePossibilitites(basedOnChangeOf index: Int) throws {
        guard let valueToRemove = board[index].solvedValue else { return }
        for indexToRemoveFrom in Constants.indiciesAffectedBy(index: index) {
            try removeAndApplyConstraints(valueToRemove: valueToRemove, indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
    mutating func removeAndApplyConstraints(valueToRemove: SudokuCell, indexToRemoveFrom: Int) throws {
        if try board[indexToRemoveFrom].remove(valueToRemove) {
            try eliminatePossibilitites(basedOnChangeOf: indexToRemoveFrom)
            if board[indexToRemoveFrom].count == 2 {
                try eliminateNakedPairs(basedOnChangeOf: indexToRemoveFrom)
            }
        }
    }
    
    mutating func unsolvedIndexWithMostConstraints() -> SudokuBoard.Index? {
        let counts = self.board.counts
        for possibleValues in 2...9 as ClosedRange<UInt8> {
            if let index = counts.indices.lazy.filter({ counts[$0] == possibleValues }).randomElement(using: &self.rng) { return index }
        }
        return nil
    }
    
    mutating func guessAndEliminate<T: SudokuCellTransformation>(transformation: T.Type) throws -> SudokuBoard {
        guard let index = self.unsolvedIndexWithMostConstraints() else { return board }
        for guess in T.transform(board[index], rng: &rng) {
            do {
                var newSolver = self
                newSolver.board[index] = guess
                try newSolver.eliminatePossibilitites(basedOnChangeOf: index)
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
        for unit in 0...8 {
            try _findHiddenSingles(for: Constants.allIndiciesInBox(number: unit))
            try _findHiddenSingles(for: Constants.allIndiciesInColumn(number: unit))
            try _findHiddenSingles(for: Constants.allIndiciesInBox(number: unit))
        }
    }
    
    mutating func _findHiddenSingles(for indicies: ArraySlice<Int>) throws {
        cellValueLoop: for cellValue in SudokuCell.allTrue {
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
            try eliminatePossibilitites(basedOnChangeOf: foundIndex)
        }
    }
    
    mutating func eliminateNakedPairs(basedOnChangeOf index: Int) throws {
        let value = board[index]
        try _eliminateNakedPairs(value: value, for: Constants.indiciesInSameRowAs(index: index))
        try _eliminateNakedPairs(value: value, for: Constants.indiciesInSameColumnAs(index: index))
        try _eliminateNakedPairs(value: value, for: Constants.indiciesInSameBoxAs(index: index))
    }
    
    mutating func _eliminateNakedPairs(value: SudokuCell, for indicies: ArraySlice<Int>) throws {
        assert(value.count == 2)
        guard let index = indicies.first(where: { board[$0] == value }) else { return }
        // Found a duplicate. Loop over all indicies, exept the current one and remove from that
        for indexToRemoveFrom in indicies where indexToRemoveFrom != index {
            guard value != board[indexToRemoveFrom] else { throw SudokuSolverError.unsolvable }
            try removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
}
