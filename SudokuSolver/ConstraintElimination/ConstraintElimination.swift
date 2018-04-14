extension SudokuBoard {
    
    func findFirstSolutionConstraintElimination() throws -> SudokuBoard {
        
        var board = try PossibleCellValuesBoard(self)
        
        // Find the relevant indicies and sort them according to the number of
        // possible values the cell can have. We do not re-sort this array later,
        // so the sorting might not be 100% correct later on, but it is a good
        // approximation, and re-sorting leads to worse performance
        var unsolvedIndicies = board.indices.filter { !board[$0].isSolved }
        unsolvedIndicies.sort { board[$0].count < board[$1].count }
        
        guard let index = unsolvedIndicies.first else {
            // Either the Sudoku was already solved or we solved it
            // with the first round of eliminatePossibilities in the
            // PossibleCellValuesBoard initializer
            return SudokuBoard(board)
        }
        
        let result = try board.guessAndEliminate(at: index, unsolvedIndicies: unsolvedIndicies, transform: NoTransformation.self)
        return SudokuBoard(result)
    }
    
    static func randomFullyFilledBoardCE() -> SudokuBoard {
        var board = PossibleCellValuesBoard.empty
        let unsolvedIndicies = Array(board.indices)
        let index = unsolvedIndicies.first!
        let result = try! board.guessAndEliminate(at: index, unsolvedIndicies: unsolvedIndicies, transform: Shuffle.self)
        return SudokuBoard(result)
    }
    
    func numberOfSolutionsCE() -> NumberOfSolutions {
        guard var board = try? PossibleCellValuesBoard(self) else { return .none }
        var unsolvedIndicies = board.indices.filter { !board[$0].isSolved }
        unsolvedIndicies.sort { board[$0].count < board[$1].count }
        guard let index = unsolvedIndicies.first else {
            // Either the Sudoku was already solved or we solved it
            // with the first round of eliminatePossibilities in the
            // PossibleCellValuesBoard initializer
            return .one
        }
        do {
            //TODO: Can this be done in paralell?
            let first = try board.guessAndEliminate(at: index, unsolvedIndicies: unsolvedIndicies, transform: NoTransformation.self)
            let last = try board.guessAndEliminate(at: index, unsolvedIndicies: unsolvedIndicies, transform: Reverse.self)
            return first == last ? .one : .multiple
        } catch {
            return .none
        }
    }
}

struct PossibleCellValuesBoard: Equatable {
    
    private var cells: FixedArray81<PossibleCellValues>
    
    init(_ board: SudokuBoard) throws {
        self.cells = FixedArray81(repeating: PossibleCellValues.allTrue)
        for (index, cell) in zip(board.indices, board) where cell != nil {
            self[index] = PossibleCellValues(solved: cell.value)
            try eliminatePossibilitites(basedOnChangeOf: index)
        }
    }
    
    static let empty: PossibleCellValuesBoard = PossibleCellValuesBoard(empty: ())
    
    private init(empty: ()) {
        self.cells = FixedArray81(repeating: PossibleCellValues.allTrue)
    }
    
}

fileprivate extension PossibleCellValuesBoard {
    
    /// Throws if we are in an impossible situation
    mutating func eliminatePossibilitites(basedOnChangeOf index: Int) throws {
        guard let valueToRemove = self[index].solvedValue else { return }
        for indexToRemoveFrom in indiciesAffectedBy(index: index) {
            try removeAndApplyConstraints(valueToRemove: valueToRemove, indexToRemoveFrom: indexToRemoveFrom)
        }
    }
    
    mutating func removeAndApplyConstraints(valueToRemove: PossibleCellValues, indexToRemoveFrom: Int) throws {
        if try self[indexToRemoveFrom].remove(valueToRemove) {
            try eliminatePossibilitites(basedOnChangeOf: indexToRemoveFrom)
            if self[indexToRemoveFrom].count == 2 {
                try eliminateNakedPairs(basedOnChangeOf: indexToRemoveFrom)
            }
        }
    }
    
    mutating func guessAndEliminate<T: PossibleCellValuesTransformation>(
        at index: Int, unsolvedIndicies: [Int], transform: T.Type) throws -> PossibleCellValuesBoard {
        var unsolvedIndicies = unsolvedIndicies
        for guess in T.transform(self[index]) {
            do {
                var newBoard = self
                newBoard[index] = guess
                try newBoard.eliminatePossibilitites(basedOnChangeOf: index)
                unsolvedIndicies.removeAll { newBoard[$0].isSolved }
                guard let index = unsolvedIndicies.first else { return newBoard }
                return try newBoard.guessAndEliminate(at: index, unsolvedIndicies: unsolvedIndicies, transform: transform.self)
            } catch {
                // Ignore the error and move on to testing the next possible value for the current index
                continue
            }
        }
        // Only fail an throw if we have tried all possible values for the current cell and all of those
        // branches failed and throwed.
        throw SudokuSolverError.unsolvable
    }
    
    mutating func eliminateNakedPairs(basedOnChangeOf index: Int) throws {
        let value = self[index]
        try _eliminateNakedPairs(value: value, for: indiciesInSameRowAs(index: index))
        try _eliminateNakedPairs(value: value, for: indiciesInSameColumnAs(index: index))
        try _eliminateNakedPairs(value: value, for: indiciesInSameBoxAs(index: index))
    }
    
    mutating func _eliminateNakedPairs(value: PossibleCellValues, for indicies: ArraySlice<Int>) throws {
        
        assert(value.count == 2)
        var iterator = value.makeIterator()
        let valuesToRemove = (iterator.next()!, iterator.next()!)
        
        // The body of this for loop will only be executed once, since it returns at the end
        for index in indicies where self[index] == value {
            // Found a duplicate. Loop over all indicies, exept the current one and remove from that
            for indexToRemoveFrom in indicies where indexToRemoveFrom != index {
                guard value != self[indexToRemoveFrom] else { throw SudokuSolverError.unsolvable }
                //TODO: Can this be done in one operation somehow?
                try removeAndApplyConstraints(valueToRemove: valuesToRemove.0, indexToRemoveFrom: indexToRemoveFrom)
                try removeAndApplyConstraints(valueToRemove: valuesToRemove.1, indexToRemoveFrom: indexToRemoveFrom)
            }
            // Once we have found a naked pair and tried to remove based on it, we return
            // since we do not need to find any additional equal pairs. If we had tried that
            // and found annother equal pair, that would have indicated that the board is unsolvable.
            return
        }
    }
    
}

extension PossibleCellValuesBoard: MutableCollection, RandomAccessCollection {
    
    subscript(position: Int) -> PossibleCellValues {
        @inline(__always) get { return cells[position] }
        @inline(__always) set { cells[position] = newValue }
    }
    
    var startIndex: Int { return cells.startIndex }
    
    var endIndex: Int { return cells.endIndex }
    
}

extension SudokuBoard {
    
    init(_ board: PossibleCellValuesBoard) {
        self.init(board.map { cell in
            if let set = cell.solvedValue {
                return SudokuCell(set)
            }
            return nil
        })
    }
    
}
