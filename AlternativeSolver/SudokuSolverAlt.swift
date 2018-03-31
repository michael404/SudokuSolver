extension SudokuBoard {
    
    func findFirstSolutionAlt() throws -> SudokuBoard {
        var board = PossibleCellValuesBoard(self)
        try board.eliminatePossibilities()
        
        //Find the relevant indicies and sort them
        var unsolvedIndicies = board.indices.filter(board.isUnsolved)
        unsolvedIndicies.sort { board[$0].count < board[$1].count }
        
        guard let index = unsolvedIndicies.first else {
            // Either the Sudoku was already solved or we solved it
            // with the first eliminatePossibilities() call
            return SudokuBoard(board)
        }
        
        let result = try _testValuesAndCallSolveAlt(board, index, unsolvedIndicies)
        return SudokuBoard(result)
    }
    
    // Returns true once the function has found a solution
    private func _solveAlt(_ board: PossibleCellValuesBoard, _ unsolvedIndicies: [Int]) throws -> PossibleCellValuesBoard {
        
        var board = board
        try board.eliminatePossibilities()
        guard let index = unsolvedIndicies.first else { return board }
        
        return try _testValuesAndCallSolveAlt(board, index, unsolvedIndicies)

    }
    
    private func _testValuesAndCallSolveAlt(_ board: PossibleCellValuesBoard, _ index: Int, _ unsolvedIndicies: [Int]) throws -> PossibleCellValuesBoard {
        var board = board
        var unsolvedIndicies = unsolvedIndicies
        // Test out possible cell values, and recurse
        for solvedCell in board[index] {
            board[index] = solvedCell
            do {
                unsolvedIndicies.removeAll(where: board.isSolved)
                return try _solveAlt(board, unsolvedIndicies)
            } catch {
                continue
            }
        }
        throw SudokuSolverError.unsolvable
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
    
    // Throws if we are in an impossible situation
    mutating func eliminatePossibilities() throws {
        var updated: Bool
        repeat {
            updated = false
            for index in 0...80 {
                guard let valueToRemove = board[index].solvedValue else { continue }
                for indexToRemoveFrom in PossibleCellValuesBoard.indiciesThatNeedToBeCheckedWhenChanging(index: index)
                    where try board[indexToRemoveFrom].remove(valueToRemove) {
                    updated = true
                }
            }
        } while updated
    }

    func isSolved(at index: Int) -> Bool {
        return self[index].isSolved
    }
    
    func isUnsolved(at index: Int) -> Bool {
        return !isSolved(at: index)
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
