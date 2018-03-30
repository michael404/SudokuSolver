internal struct SudokuValidator {
    
    private var rows = Mask()
    private var columns = Mask()
    private var blocks = Mask()
    
    init() { }
    
    init(_ board: SudokuBoard) {
        for i in board.indices where board[i] != nil {
            set(board[i].value, to: true, at: SudokuCoordinate(i))
        }
    }
    
    func validate(_ cell: Int, at coordinate: SudokuCoordinate) -> Bool {
        if self.rows[coordinate.row, cell] { return false }
        if self.columns[coordinate.column, cell] { return false }
        if self.blocks[coordinate.block, cell] { return false }
        return true
    }
    
    mutating func set(_ cell: Int, to newValue: Bool, at coordinate: SudokuCoordinate) {
        self.rows[coordinate.row, cell] = newValue
        self.columns[coordinate.column, cell] = newValue
        self.blocks[coordinate.block, cell] = newValue
    }
    
}



extension SudokuValidator {
    
    struct Mask {
        
        private var _storage: (UInt64, UInt64) = (0, 0)
        
        subscript(part: Int, cellValue: Int) -> Bool {
            get {
                let index = part * 10 + cellValue
                if index < 64 {
                    return ((_storage.0 >> index) & 1) == 1
                } else {
                    let index = index &- 64
                    return ((_storage.1 >> index) & 1) == 1
                }
            }
            set {
                let index = part * 10 + cellValue
                if index < 64 {
                    let oldValue = ((_storage.0 >> index) & 1) == 1
                    switch oldValue {
                    case newValue: return
                    case true: _storage.0 = 1 << index ^ _storage.0
                    case false: _storage.0 = 1 << index | _storage.0
                    }
                } else {
                    let index = index &- 64
                    let oldValue = ((_storage.1 >> index) & 1) == 1
                    switch oldValue {
                    case newValue: return
                    case true: _storage.1 = 1 << index ^ _storage.1
                    case false: _storage.1 = 1 << index | _storage.1
                    }
                }
            }
        }
    }
    
}
