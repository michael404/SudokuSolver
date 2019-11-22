extension SudokuBoard {
    
    func findFirstSolution() throws -> SudokuBoard {
        
        var board = try SudokuBoard(eliminating: self)
        
        // Find the relevant indicies and sort them according to the number of
        // possible values the cell can have. We do not re-sort this array later,
        // so the sorting might not be 100% correct later on, but it is a good
        // approximation, and re-sorting leads to worse performance
        var unsolvedIndicies = board.indices.filter { !board[$0].isSolved }
        unsolvedIndicies.sort { board[$0].count < board[$1].count }
        
        return try board.guessAndEliminate(unsolvedIndicies: unsolvedIndicies, transformation: Normal.self)
    }
    
    static func randomFullyFilledBoard() -> SudokuBoard {
        var rng = SystemRandomNumberGenerator()
        return randomFullyFilledBoard(rng: &rng)
    }
    
    static func randomFullyFilledBoard<R: RNG>(rng: inout R) -> SudokuBoard {
        var board = SudokuBoard.empty
        let unsolvedIndicies = Array(board.indices)
        return try! board.guessAndEliminate(unsolvedIndicies: unsolvedIndicies, transformation: Shuffle.self, rng: &rng)
    }
    
    enum NumberOfSolutions {
        case none
        case one
        case multiple
    }
    
    func numberOfSolutions() -> NumberOfSolutions {
        guard var board = try? SudokuBoard(eliminating: self) else { return .none }
        var unsolvedIndicies = board.indices.filter { !board[$0].isSolved }
        unsolvedIndicies.sort { board[$0].count < board[$1].count }
        do {
            //TODO: Can this be done in paralell?
            let first = try board.guessAndEliminate(unsolvedIndicies: unsolvedIndicies, transformation: Normal.self)
            let last = try board.guessAndEliminate(unsolvedIndicies: unsolvedIndicies, transformation: Reverse.self)
            return first == last ? .one : .multiple
        } catch {
            return .none
        }
    }
}

fileprivate extension SudokuBoard {
    
    init(eliminating board: SudokuBoard) throws {
        self = board
        for (index, cell) in zip(self.indices, self) where cell.isSolved {
            try eliminatePossibilitites(basedOnChangeOf: index)
        }
    }
    
    /// Throws if we are in an impossible situation
    mutating func eliminatePossibilitites(basedOnChangeOf index: Int) throws {
        guard let valueToRemove = self[index].solvedValue else { return }
        for indexToRemoveFrom in indiciesAffectedBy(index: index) {
            try removeAndApplyConstraints(valueToRemove: valueToRemove, indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
    mutating func removeAndApplyConstraints(valueToRemove: SudokuCell, indexToRemoveFrom: Int) throws {
        if try self[indexToRemoveFrom].remove(valueToRemove) {
            try eliminatePossibilitites(basedOnChangeOf: indexToRemoveFrom)
            if self[indexToRemoveFrom].count == 2 {
                try eliminateNakedPairs(basedOnChangeOf: indexToRemoveFrom)
            }
        }
    }
    
    mutating func guessAndEliminate<T: SudokuCellTransformation>(
        unsolvedIndicies: [Int], transformation: T.Type) throws -> SudokuBoard {
        var rng = SystemRandomNumberGenerator()
        return try guessAndEliminate(unsolvedIndicies: unsolvedIndicies, transformation: transformation, rng: &rng)
    }
    
    mutating func guessAndEliminate<T: SudokuCellTransformation, R: RNG>(
        unsolvedIndicies: [Int], transformation: T.Type, rng: inout R) throws -> SudokuBoard {
        guard let index = unsolvedIndicies.first else { return self }
        for guess in T.transform(self[index], rng: &rng) {
            do {
                var newBoard = self
                newBoard[index] = guess
                try newBoard.eliminatePossibilitites(basedOnChangeOf: index)
                try newBoard.findAllHiddenSingles()
                var unsolvedIndicies = unsolvedIndicies
                unsolvedIndicies.removeAll { newBoard[$0].isSolved }
                return try newBoard.guessAndEliminate(unsolvedIndicies: unsolvedIndicies, transformation: transformation, rng: &rng)
            } catch {
                // Ignore the error and move on to testing the next possible value for the current index
                continue
            }
        }
        // Only fail and throw if we have tried all possible values for the current cell and all of those
        // branches failed and throwed.
        throw SudokuSolverError.unsolvable
    }
    
    mutating func findAllHiddenSingles() throws {
        for unit in 0...8 {
            try _findHiddenSingles(for: allIndiciesInBox(number: unit))
            try _findHiddenSingles(for: allIndiciesInColumn(number: unit))
            try _findHiddenSingles(for: allIndiciesInBox(number: unit))
        }
    }
    
    mutating func _findHiddenSingles(for indicies: ArraySlice<Int>) throws {
        cellValueLoop: for cellValue in SudokuCell.allTrue {
            var foundIndex = -1
            for index in indicies where self[index].contains(cellValue) {
                // If we have already found one value in this unit, it is not a candiadate for a hidden single
                guard foundIndex == -1 else { continue cellValueLoop }
                // If we have found a solved value, that is not a candidate for a hidden single
                guard !self[index].isSolved else { continue cellValueLoop }
                foundIndex = index
            }
            // If we did not find the value at all, the board is unsolvable
            guard foundIndex != -1 else { throw SudokuSolverError.unsolvable }
            // We have identified a hidden single, and can set the cell to that value
            self[foundIndex] = cellValue
            try eliminatePossibilitites(basedOnChangeOf: foundIndex)
        }
    }
    
    mutating func eliminateNakedPairs(basedOnChangeOf index: Int) throws {
        let value = self[index]
        try _eliminateNakedPairs(value: value, for: indiciesInSameRowAs(index: index))
        try _eliminateNakedPairs(value: value, for: indiciesInSameColumnAs(index: index))
        try _eliminateNakedPairs(value: value, for: indiciesInSameBoxAs(index: index))
    }
    
    mutating func _eliminateNakedPairs(value: SudokuCell, for indicies: ArraySlice<Int>) throws {
        assert(value.count == 2)
        guard let index = indicies.first(where: { self[$0] == value }) else { return }
        // Found a duplicate. Loop over all indicies, exept the current one and remove from that
        for indexToRemoveFrom in indicies where indexToRemoveFrom != index {
            guard value != self[indexToRemoveFrom] else { throw SudokuSolverError.unsolvable }
            try removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
}
