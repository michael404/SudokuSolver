extension SudokuBoard {
    
    func findFirstSolutionAlt() throws -> SudokuBoard {
        var board = PossibleCellValuesBoard(self)
        try board.eliminatePossibilities()
        
        // Find the relevant indicies and sort them according to the number of
        // possible values the cell can have. We do not resort this array later,
        // so the sorting might not be 100% correct later on, but it is a good
        // approximation, and resorting leads to worse performance
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
    
    var board: FixedArray81<PossibleCellValues>
    
    init(_ board: SudokuBoard) {
        self.board = FixedArray81(repeating: PossibleCellValues(allTrue: ()))
        for (index, cell) in zip(board.indices, board) where cell != nil {
            self.board[index] = PossibleCellValues(solved: cell.value)
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
    
    // Throws if we are in an impossible situation
    mutating func eliminatePossibilities() throws {
        var updated: Bool
        repeat {
            updated = false
            for index in self.indices {
                guard let valueToRemove = board[index].solvedValue else { continue }
                for indexToRemoveFrom in PossibleCellValuesBoard.indiciesThatNeedToBeCheckedWhenChanging(index: index)
                    where try board[indexToRemoveFrom].remove(valueToRemove) {
                    updated = true
                }
            }
        } while updated
    }
    
    mutating func bruteforceAndEliminate(at index: Int, unsolvedIndicies: [Int]) throws -> PossibleCellValuesBoard {
        var unsolvedIndicies = unsolvedIndicies
        for solvedCell in self[index] {
            self[index] = solvedCell
            do {
                unsolvedIndicies.removeAll(where: self.isSolved)
                guard let index = unsolvedIndicies.first else { return self }
                var newBoard = self
                try newBoard.eliminatePossibilities()
                return try newBoard.bruteforceAndEliminate(at: index, unsolvedIndicies: unsolvedIndicies)
            } catch {
                continue
            }
        }
        throw SudokuSolverError.unsolvable
    }
    
}

extension PossibleCellValuesBoard: MutableCollection, RandomAccessCollection {
    
    typealias Element = PossibleCellValues
    typealias Index = Int
    typealias SubSequence = PossibleCellValuesBoard
    
    subscript(position: Int) -> PossibleCellValues {
        get {
            return board[position]
        }
        set(newValue) {
            board[position] = newValue
        }
    }
    
    var startIndex: Int {
        return board.startIndex
    }
    
    var endIndex: Int {
        return board.endIndex
    }
    
}

fileprivate extension SudokuBoard {
    
    init(_ board: PossibleCellValuesBoard) {
        self.init(board.map { cell in
            if let set = cell.solvedValue {
                return SudokuCell(Int(set))
            }
            return nil
        })
    }
    
}
