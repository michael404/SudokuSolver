struct SudokuSolver {
    
    let initialBoard: SudokuBoard
    
    init(_ board: SudokuBoard) throws {
        guard board.isValid() else { throw SudokuSolverError.unsolvable }
        guard !board.isFullyFilled() else { throw SudokuSolverError.boardAllreadyFilled }
        self.initialBoard = board
    }
    
    func solve() throws -> SudokuBoard {
        var board = self.initialBoard
        let modifiableIndicies = board.indices.filter { board[$0] == .empty }
        guard solve(board: &board, modifiableIndicies: modifiableIndicies, startAt: 0) else {
            throw SudokuSolverError.unsolvable
        }
        return board
    }
    
    // returns true if it found a valid board in this recursive branch, false otherwise
    func solve(board: inout SudokuBoard, modifiableIndicies: [Int], startAt index: Int) -> Bool {
        
        // Reached end
        if index == modifiableIndicies.endIndex { return true }
        
        for cell in SudokuCell.allNonEmpyValues {
            board[modifiableIndicies[index]] = cell
            if board.isValid() {
                if solve(board: &board, modifiableIndicies: modifiableIndicies, startAt: index + 1) {
                    return true
                }
            }
        }
        // Tried all possible values for this cell without finding a valid one, so returning false
        board[modifiableIndicies[index]] = .empty
        return false
        
        
    }
    
}

