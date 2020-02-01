protocol SudokuTypeProtocol {
    associatedtype Cell: SudokuCellProtocol
    static var sideOfBox: Int { get }
    static var constants: ConstantsStorage<Self> { get }
}

extension SudokuTypeProtocol {
    static var possibilities: Int { sideOfBox * sideOfBox }
    static var allPossibilities: Range<Int> { 0..<possibilities }
    static var cells: Int { possibilities * possibilities }
    static var allCells: Range<Int> { 0..<cells }
}

enum Sudoku4: SudokuTypeProtocol {
    typealias Cell = SudokuCell4
    static var sideOfBox: Int { 2 }
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku9: SudokuTypeProtocol {
    typealias Cell = SudokuCell9
    static var sideOfBox: Int { 3 }
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku16: SudokuTypeProtocol {
    typealias Cell = SudokuCell16
    static var sideOfBox: Int { 4 }
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}

typealias SudokuBoard4 = SudokuBoard<Sudoku4>
typealias SudokuBoard9 = SudokuBoard<Sudoku9>
typealias SudokuBoard16 = SudokuBoard<Sudoku16>
