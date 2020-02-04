protocol SudokuTypeProtocol {
    associatedtype CellStorage: BinaryInteger & FixedWidthInteger
    associatedtype CellIteratorStorage: SudokuCellIteratorStorageProtocol
    static var allTrueCellStorage: CellStorage { get }
    static var sideOfBox: Int { get }
    static var solvedRepresentation: [String] { get }
    static var constants: ConstantsStorage<Self> { get }
}

extension SudokuTypeProtocol {
    static var possibilities: Int { sideOfBox * sideOfBox }
    static var allPossibilities: Range<Int> { 0..<possibilities }
    static var cells: Int { possibilities * possibilities }
    static var allCells: Range<Int> { 0..<cells }
    //TODO: Consider if this needs to be a stored property on the concrete types instead
    static var solvedRepresentationReversed: [String: Int] {
        assert(solvedRepresentation.count == possibilities, "solvedRepresentation count was not \(possibilities) as expected")
        return Dictionary.init(uniqueKeysWithValues: solvedRepresentation.enumerated().map { ($1, $0) })
    }
}

enum Sudoku4: SudokuTypeProtocol {
    typealias CellStorage = UInt8
    typealias CellIteratorStorage = Int8
    static var allTrueCellStorage: UInt8 = 0b1111
    static var sideOfBox: Int { 2 }
    static var solvedRepresentation = (1...4).map(String.init)
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku9: SudokuTypeProtocol {
    typealias CellStorage = UInt16
    typealias CellIteratorStorage = Int16
    static var allTrueCellStorage: UInt16 = 0b111111111
    static var sideOfBox: Int { 3 }
    static var solvedRepresentation = (1...9).map(String.init)
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku16: SudokuTypeProtocol {
    typealias CellStorage = UInt16
    typealias CellIteratorStorage = Int32
    static var allTrueCellStorage: UInt16 = 0b11111111_11111111
    static var sideOfBox: Int { 4 }
    static var solvedRepresentation = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku25: SudokuTypeProtocol {
    typealias CellStorage = UInt32
    typealias CellIteratorStorage = Int32
    static var allTrueCellStorage: UInt32 = 0b11111_11111_11111_11111_11111
    static var sideOfBox: Int { 5 }
    static var solvedRepresentation = (65...89).map { String(UnicodeScalar($0)) } // "A"..."Z"
    static var constants: ConstantsStorage<Self> = ConstantsStorage()
}

typealias SudokuBoard4 = SudokuBoard<Sudoku4>
typealias SudokuBoard9 = SudokuBoard<Sudoku9>
typealias SudokuBoard16 = SudokuBoard<Sudoku16>
typealias SudokuBoard25 = SudokuBoard<Sudoku25>


typealias SudokuCell4 = SudokuCell<Sudoku4>
typealias SudokuCell9 = SudokuCell<Sudoku9>
typealias SudokuCell16 = SudokuCell<Sudoku16>
typealias SudokuCell25 = SudokuCell<Sudoku25>

