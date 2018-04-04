internal struct SudokuCoordinate {
    
    let index: Int
    let row: Int
    let column: Int
    let block: Int
    
    init(_ index: Int) {
        self.index = index
        self.row = index / 9
        self.column = index % 9
        self.block = (self.row / 3) * 3 + (self.column / 3)
    }
    
}
