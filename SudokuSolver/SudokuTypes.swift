protocol SudokuTypeProtocol: Sendable {
    associatedtype CellStorage: BinaryInteger & FixedWidthInteger & Sendable
    associatedtype CellIteratorStorage: SignedInteger & FixedWidthInteger & Sendable
    static var allTrueCellStorage: CellStorage { get }
    static var sideOfBox: Int { get }
    static var solvedRepresentation: [String] { get }
    /// Maps each symbol in `solvedRepresentation` back to its value.
    /// Stored per conforming type so it is built once, not on every lookup.
    static var solvedRepresentationReversed: [String: Int] { get }
    static var constants: ConstantsStorage<Self> { get }
}

extension SudokuTypeProtocol {
    static var possibilities: Int { sideOfBox * sideOfBox }
    static var allPossibilities: Range<Int> { 0..<possibilities }
    static var cells: Int { possibilities * possibilities }
    static var allCells: Range<Int> { 0..<cells }
    /// Builds the reverse lookup for `solvedRepresentationReversed`. Each
    /// conforming type stores the result in a `static let` so this runs once.
    static func makeSolvedRepresentationReversed() -> [String: Int] {
        assert(solvedRepresentation.count == possibilities,
               "solvedRepresentation count was not \(possibilities) as expected")
        return Dictionary(uniqueKeysWithValues: solvedRepresentation.enumerated().map { ($1, $0) })
    }
}

enum Sudoku4: SudokuTypeProtocol {
    typealias CellStorage = UInt8
    typealias CellIteratorStorage = Int8
    static let allTrueCellStorage: UInt8 = 0b1111
    static var sideOfBox: Int { 2 }
    static let solvedRepresentation = (1...4).map(String.init)
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku9: SudokuTypeProtocol {
    typealias CellStorage = UInt16
    typealias CellIteratorStorage = Int16
    static let allTrueCellStorage: UInt16 = 0b111111111
    static var sideOfBox: Int { 3 }
    static let solvedRepresentation = (1...9).map(String.init)
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku16: SudokuTypeProtocol {
    typealias CellStorage = UInt16
    typealias CellIteratorStorage = Int32
    static let allTrueCellStorage: UInt16 = 0b11111111_11111111
    static var sideOfBox: Int { 4 }
    static let solvedRepresentation = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku25: SudokuTypeProtocol {
    typealias CellStorage = UInt32
    typealias CellIteratorStorage = Int32
    static let allTrueCellStorage: UInt32 = 0b11111_11111_11111_11111_11111
    static var sideOfBox: Int { 5 }
    static let solvedRepresentation = (65...89).map { String(UnicodeScalar($0)) } // "A"..."Y"
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

typealias SudokuBoard4 = SudokuBoard<Sudoku4>
typealias SudokuBoard9 = SudokuBoard<Sudoku9>
typealias SudokuBoard16 = SudokuBoard<Sudoku16>
typealias SudokuBoard25 = SudokuBoard<Sudoku25>

typealias SudokuCell4 = SudokuCell<Sudoku4>
typealias SudokuCell9 = SudokuCell<Sudoku9>
typealias SudokuCell16 = SudokuCell<Sudoku16>
typealias SudokuCell25 = SudokuCell<Sudoku25>
