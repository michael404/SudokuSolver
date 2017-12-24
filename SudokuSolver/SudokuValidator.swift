struct SudokuValidator {

    fileprivate struct Mask {
        private var s1, s2: UInt64
        init() { (s1, s2) = (0, 0) }
    }
    
    private var rows = Mask()
    private var columns = Mask()
    private var blocks = Mask()
    
    init() { }
    
    init(_ board: SudokuBoard) {
        for i in board.indices where board[i] != nil {
            set(board[i].cell, to: true, at: SudokuCoordinate(i))
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

extension SudokuValidator.Mask {
    
    subscript(part: Int, cellValue: Int) -> Bool {
        get {
            let (useS1, index) = _storageAndIndex(_index(part, cellValue: cellValue))
            return _getValueNoBoundsCheck(useS1: useS1, index: index)
        }
        set {
            let (useS1, index) = _storageAndIndex(_index(part, cellValue: cellValue))
            let oldValue = _getValueNoBoundsCheck(useS1: useS1, index: index)
            guard oldValue != newValue else { return }
            let bitMask = ((1 as UInt64) << index)
            if useS1 {
                s1 = oldValue ? bitMask ^ s1 : bitMask | s1
            } else {
                s2 = oldValue ? bitMask ^ s2 : bitMask | s2
            }
        }
    }
    
    private func _index(_ part: Int, cellValue: Int) -> Int {
        return part * 10 + cellValue
    }
    
    private func _storageAndIndex(_ index: Int) -> (useS1: Bool, index: Int) {
        if index >= 0 {
            if index < 64 { return (true, index) }
            if index < 128 { return (false, index - 64) }
        }
        fatalError("Index out of bounds")
    }
    
    private func _getValueNoBoundsCheck(useS1: Bool, index: Int) -> Bool {
        return (((useS1 ? s1 : s2) >> index) & 1) == 1
    }
        
}
