extension SudokuBoard {
    
    func findFirstSolutionConstraintElimination() throws -> SudokuBoard {
        var board = try PossibleCellValuesBoard(self)
        
        // Find the relevant indicies and sort them according to the number of
        // possible values the cell can have. We do not re-sort this array later,
        // so the sorting might not be 100% correct later on, but it is a good
        // approximation, and re-sorting leads to worse performance
        var unsolvedIndicies = board.indices.filter(board.isUnsolved)
        unsolvedIndicies.sort { board[$0].count < board[$1].count }
        
        guard let index = unsolvedIndicies.first else {
            // Either the Sudoku was already solved or we solved it
            // with the first eliminatePossibilities() call
            return SudokuBoard(board)
        }
        
        let result = try board.bruteforceAndEliminate(at: index, unsolvedIndicies: unsolvedIndicies)
        return SudokuBoard(result)
    }
    
}

struct PossibleCellValuesBoard {
    
    private var cells: FixedArray81<PossibleCellValues>
    
    init(_ board: SudokuBoard) throws {
        self.cells = FixedArray81(repeating: PossibleCellValues(allTrue: ()))
        for (index, cell) in zip(board.indices, board) where cell != nil {
            self[index] = PossibleCellValues(solved: cell.value)
            try eliminatePossibilitites(basedOnChangeOf: index)
        }
    }
    
    func isSolved(at index: Int) -> Bool {
        return self[index].isSolved
    }
    
    func isUnsolved(at index: Int) -> Bool {
        return !isSolved(at: index)
    }
    
}

fileprivate extension PossibleCellValuesBoard {
    
    /// Throws if we are in an impossible situation
    mutating func eliminatePossibilitites(basedOnChangeOf index: Int) throws {
        guard let valueToRemove = self[index].solvedValue else { return }
        for indexToRemoveFrom in indiciesAffectedBy(index: index) where try self[indexToRemoveFrom].remove(valueToRemove) {
            try eliminatePossibilitites(basedOnChangeOf: indexToRemoveFrom)
        }
    }
    
    mutating func bruteforceAndEliminate(at index: Int, unsolvedIndicies: [Int]) throws -> PossibleCellValuesBoard {
        var unsolvedIndicies = unsolvedIndicies
        for solvedCell in self[index] {
            self[index] = solvedCell //TODO: Should this be done on newBoard instead?
            do {
                var newBoard = self
                try newBoard.eliminatePossibilitites(basedOnChangeOf: index)
                unsolvedIndicies.removeAll(where: self.isSolved)
                guard let index = unsolvedIndicies.first else { return self }
                return try newBoard.bruteforceAndEliminate(at: index, unsolvedIndicies: unsolvedIndicies)
            } catch {
                // Ignore the error and move on to testing the next possible value for the current index
                continue
            }
        }
        // Only fail an throw if we have tried all possible values for the current cell and all of those
        // branches failed and throwed.
        throw SudokuSolverError.unsolvable
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
