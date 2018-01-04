struct SudokuSolver {
    
    let initialBoard: SudokuBoard
    
    init(_ board: SudokuBoard) throws {
        guard board.isValid() else { throw SudokuSolverError.unsolvable }
        guard !board.isFullyFilled() else { throw SudokuSolverError.boardAlreadyFilled }
        self.initialBoard = board
    }
    
    func solve() throws -> SudokuBoard {
        
        var board = self.initialBoard
        let indiciesIterator = board.indices.filter { board[$0] == nil }.makeIterator()
        var validator = SudokuValidator(board)
        
        func _solve(_ indiciesIterator: Array<Int>.Iterator) -> Bool {
            var indiciesIterator = indiciesIterator
            
            // Check if we reached the end
            guard let index = indiciesIterator.next() else { return true }
            
            for cell in (1...9) {
                board[index] = SudokuCell(cell)
                let coordinate = SudokuCoordinate(index)
                if validator.validate(cell, at: coordinate) {
                    validator.set(cell, to: true, at: coordinate)
                    if _solve(indiciesIterator) {
                        return true
                    } else {
                        validator.set(cell, to: false, at: coordinate)
                    }
                }
            }
            // Tried all possible values for this cell without finding a valid one, so returning false
            board[index] = nil
            return false
        }
        
        guard _solve(indiciesIterator) else {
            throw SudokuSolverError.unsolvable
        }
        return board
    }
    
}
