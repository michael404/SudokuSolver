struct SudokuSolver {
    
    let initialBoard: SudokuBoard
    
    init(_ board: SudokuBoard) throws {
        guard board.isValid() else { throw SudokuSolverError.unsolvable }
        guard !board.isFullyFilled() else { throw SudokuSolverError.boardAllreadyFilled }
        self.initialBoard = board
    }
    
    func solve() throws -> SudokuBoard {
        var board = self.initialBoard
        let indiciesIterator = board.indices.filter { board[$0] == .empty }.makeIterator()
        var validator = SudokuValidator(board)
        guard _solve(board: &board, indiciesIterator: indiciesIterator, validator: &validator) else {
            throw SudokuSolverError.unsolvable
        }
        return board
    }
    
    private func _solve(board: inout SudokuBoard, indiciesIterator: Array<Int>.Iterator, validator: inout SudokuValidator) -> Bool {
        var indiciesIterator = indiciesIterator
        
        // Check if we reached the end
        guard let index = indiciesIterator.next() else { return true }
        
        for cell in SudokuCell.allNonEmpyValues {
            board[index] = cell
            let coordinate = SudokuCoordinate(index)
            if validator.validate(cell, for: coordinate) {
                validator.set(cell, for: coordinate)
                if _solve(board: &board, indiciesIterator: indiciesIterator, validator: &validator) {
                    return true
                } else {
                    validator.unset(cell, for: coordinate)
                }
            }
        }
        // Tried all possible values for this cell without finding a valid one, so returning false
        board[index] = .empty
        return false
    }
    
}

