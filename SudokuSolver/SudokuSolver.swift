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
        guard _solve(board: &board, indiciesIterator: indiciesIterator) else {
            throw SudokuSolverError.unsolvable
        }
        return board
    }
    
    // returns true if it found a valid board in this recursive branch, false otherwise
    private func _solve(board: inout SudokuBoard, indiciesIterator: Array<Int>.Iterator) -> Bool {
        var indiciesIterator = indiciesIterator
        
        // Check if we reached the end
        guard let index = indiciesIterator.next() else { return true }
        
        for cell in SudokuCell.allNonEmpyValues {
            board[index] = cell
            if board.isValid() && _solve(board: &board, indiciesIterator: indiciesIterator) {
                return true
            }
        }
        // Tried all possible values for this cell without finding a valid one, so returning false
        board[index] = .empty
        return false
    }
    
}

