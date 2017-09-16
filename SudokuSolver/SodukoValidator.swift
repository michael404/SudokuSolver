struct SodukoValidator {
    
    var rows = Array(repeating: Array(repeating: false, count: 10), count: 9)
    var columns = Array(repeating: Array(repeating: false, count: 10), count: 9)
    var blocks = Array(repeating: Array(repeating: false, count: 10), count: 9)
    
    init() { }
    
    init(_ board: SudokuBoard) {
        for i in board.indices.filter({ board[$0] != .empty }) {
            set(board[i], for: SodukoCoordinate(i))
        }
    }
    
    func validate(_ cell: SudokuCell, for coordinate: SodukoCoordinate) -> Bool {
        if self.rows[coordinate.row][cell.rawValue] { return false }
        if self.columns[coordinate.column][cell.rawValue] { return false }
        if self.blocks[coordinate.block][cell.rawValue] { return false }
        return true
    }
    
    mutating func set(_ cell: SudokuCell, for coordinate: SodukoCoordinate) {
        self.rows[coordinate.row][cell.rawValue] = true
        self.columns[coordinate.column][cell.rawValue] = true
        self.blocks[coordinate.block][cell.rawValue] = true
    }
    
    mutating func unset(_ cell: SudokuCell, for coordinate: SodukoCoordinate) {
        rows[coordinate.row][cell.rawValue] = false
        columns[coordinate.column][cell.rawValue] = false
        blocks[coordinate.block][cell.rawValue] = false
    }
    
}
