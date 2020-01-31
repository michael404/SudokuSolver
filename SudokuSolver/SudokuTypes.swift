protocol SudokuType {
    static var sideOfBox: Int { get }
    static var constants: ConstantsStorage<Self> { get }
}

extension SudokuType {
    static var possibilities: Int { sideOfBox * sideOfBox }
    static var allPossibilities: Range<Int> { 0..<possibilities }
    static var cells: Int { possibilities * possibilities }
    static var allCells: Range<Int> { 0..<cells }
}

enum Sudoku9: SudokuType {
    static var sideOfBox: Int { 3 }
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku16: SudokuType {
    static var sideOfBox: Int { 4 }
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}
