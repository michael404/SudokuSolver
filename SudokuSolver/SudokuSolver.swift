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
        var helper = Validator(board)
        guard _solve(board: &board, indiciesIterator: indiciesIterator, helper: &helper) else {
            throw SudokuSolverError.unsolvable
        }
        return board
    }
    
    private func _solve(board: inout SudokuBoard, indiciesIterator: Array<Int>.Iterator, helper: inout Validator) -> Bool {
        var indiciesIterator = indiciesIterator
        
        // Check if we reached the end
        guard let index = indiciesIterator.next() else { return true }
        
        for cell in SudokuCell.allNonEmpyValues {
            board[index] = cell
            let coordinate = Coordinate(index)
            if helper.validate(cell, for: coordinate) {
                helper.set(cell, for: coordinate)
                if _solve(board: &board, indiciesIterator: indiciesIterator, helper: &helper) {
                    return true
                } else {
                    helper.unset(cell, for: coordinate)
                }
            }
        }
        // Tried all possible values for this cell without finding a valid one, so returning false
        board[index] = .empty
        return false
    }
    
    private struct Validator {
        
        var rows = Array(repeating: Array(repeating: false, count: 10), count: 9)
        var columns = Array(repeating: Array(repeating: false, count: 10), count: 9)
        var blocks = Array(repeating: Array(repeating: false, count: 10), count: 9)
        
        init(_ board: SudokuBoard) {
            for i in board.indices.filter({ board[$0] != .empty }) {
                set(board[i], for: Coordinate(i))
            }
        }
        
        func validate(_ cell: SudokuCell, for coordinate: Coordinate) -> Bool {
            guard !self.rows[coordinate.row][cell.rawValue] else { return false }
            guard !self.columns[coordinate.column][cell.rawValue] else { return false }
            guard !self.blocks[coordinate.block][cell.rawValue] else { return false }
            return true
        }
        
        mutating func set(_ cell: SudokuCell, for coordinate: Coordinate) {
            self.rows[coordinate.row][cell.rawValue] = true
            self.columns[coordinate.column][cell.rawValue] = true
            self.blocks[coordinate.block][cell.rawValue] = true
        }
        
        mutating func unset(_ cell: SudokuCell, for coordinate: Coordinate) {
            rows[coordinate.row][cell.rawValue] = false
            columns[coordinate.column][cell.rawValue] = false
            blocks[coordinate.block][cell.rawValue] = false
        }
        
    }

    private struct Coordinate {
        
        let row: Int
        let column: Int
        let block: Int
        
        init(_ index: Int) {
            self.row = index / 9
            self.column = index % 9
            self.block = (self.row / 3) * 3 + (self.column / 3)
        }
        
    }
    
    
}

