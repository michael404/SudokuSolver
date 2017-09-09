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
    
    //todo: Only validate current row!
    
    
    /// Private solving method
    ///
    /// - Parameters:
    ///   - board: The board that we are trying to solve. This is passed as an
    ///            inout parameter and needs to be reset if a branch does not find
    ///            any valid solutions
    ///   - indiciesIterator: An iterator over the indicies on the board that can be filled,
    ///                       i.e. that are not filled in the initial board
    /// - Returns: true if a valid fully filled solution was found, false otherwise.
    private func _solve(board: inout SudokuBoard, indiciesIterator: Array<Int>.Iterator) -> Bool {
        var indiciesIterator = indiciesIterator
        
        // Check if we reached the end
        guard let index = indiciesIterator.next() else { return true }
        
        for cell in SudokuCell.allNonEmpyValues {
            board[index] = cell
            if board.isValid(for: index) && _solve(board: &board, indiciesIterator: indiciesIterator) {
                return true
            }
        }
        // Tried all possible values for this cell without finding a valid one, so returning false
        board[index] = .empty
        return false
    }
    
}

