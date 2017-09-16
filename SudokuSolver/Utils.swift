enum SudokuSolverError: Error {
    
    case unsolvable
    case boardAllreadyFilled
    
}

struct SudokuCoordinate {
    
    let row: Int
    let column: Int
    let block: Int
    
    init(_ index: Int) {
        self.row = index / 9
        self.column = index % 9
        self.block = (self.row / 3) * 3 + (self.column / 3)
    }
    
}
