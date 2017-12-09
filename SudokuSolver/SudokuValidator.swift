struct SudokuValidator {
    
    private var rows = Array(repeating: Array(repeating: false, count: 10), count: 9)
    private var columns = Array(repeating: Array(repeating: false, count: 10), count: 9)
    private var blocks = Array(repeating: Array(repeating: false, count: 10), count: 9)
    
    init() { }
    
    init(_ board: SudokuBoard) {
        for i in board.indices {
            if let cell = board[i].cell {
                set(cell, at: SudokuCoordinate(i))
            }
        }
    }
    
    func validate(_ cell: Int, at coordinate: SudokuCoordinate) -> Bool {
        if self.rows[coordinate.row][cell] { return false }
        if self.columns[coordinate.column][cell] { return false }
        if self.blocks[coordinate.block][cell] { return false }
        return true
    }
    
    mutating func set(_ cell: Int, at coordinate: SudokuCoordinate) {
        self.rows[coordinate.row][cell] = true
        self.columns[coordinate.column][cell] = true
        self.blocks[coordinate.block][cell] = true
    }
    
    mutating func unset(_ cell: Int, at coordinate: SudokuCoordinate) {
        rows[coordinate.row][cell] = false
        columns[coordinate.column][cell] = false
        blocks[coordinate.block][cell] = false
    }
    
}
