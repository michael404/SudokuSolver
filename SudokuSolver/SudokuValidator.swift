struct SudokuValidator {
    
    private var rows = Array(repeating: Array(repeating: false, count: 10), count: 9)
    private var columns = Array(repeating: Array(repeating: false, count: 10), count: 9)
    private var blocks = Array(repeating: Array(repeating: false, count: 10), count: 9)
    
    init() { }
    
    init(_ board: SudokuBoard) {
        for i in board.indices.filter({ board[$0] != .empty }) {
            set(board[i], at: SudokuCoordinate(i))
        }
    }
    
    func validate(_ cell: SudokuCell, at coordinate: SudokuCoordinate) -> Bool {
        if self.rows[coordinate.row][cell.rawValue] { return false }
        if self.columns[coordinate.column][cell.rawValue] { return false }
        if self.blocks[coordinate.block][cell.rawValue] { return false }
        return true
    }
    
    mutating func set(_ cell: SudokuCell, at coordinate: SudokuCoordinate) {
        self.rows[coordinate.row][cell.rawValue] = true
        self.columns[coordinate.column][cell.rawValue] = true
        self.blocks[coordinate.block][cell.rawValue] = true
    }
    
    mutating func unset(_ cell: SudokuCell, at coordinate: SudokuCoordinate) {
        rows[coordinate.row][cell.rawValue] = false
        columns[coordinate.column][cell.rawValue] = false
        blocks[coordinate.block][cell.rawValue] = false
    }
    
}
