protocol SudokuTypeProtocol: Sendable {
    associatedtype CellStorage: BinaryInteger & FixedWidthInteger & Sendable
    associatedtype CellIteratorStorage: SignedInteger & FixedWidthInteger & Sendable
    /// Fixed-size inline storage for all cells of a board, so that copying a board is
    /// a flat memcpy with no heap allocation, reference counting or copy-on-write
    /// checks. Must be at least `cells * CellStorage` bytes. `SudokuBoard` reinterprets
    /// the raw bytes as cells and keeps any trailing padding zeroed, so the synthesized
    /// equality of this type matches cell-wise equality.
    associatedtype BoardStorage: Hashable & Sendable
    static var zeroBoardStorage: BoardStorage { get }
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
    struct BoardStorage: Hashable, Sendable {
        var cells0 = SIMD16<UInt8>() // 16 bytes ≥ 16 cells × 1 byte
    }
    static var zeroBoardStorage: BoardStorage { BoardStorage() }
    static let allTrueCellStorage: UInt8 = 0b1111
    static var sideOfBox: Int { 2 }
    static let solvedRepresentation = (1...4).map(String.init)
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku9: SudokuTypeProtocol {
    typealias CellStorage = UInt16
    typealias CellIteratorStorage = Int16
    struct BoardStorage: Hashable, Sendable {
        var cells0 = SIMD64<UInt16>() // 192 bytes ≥ 81 cells × 2 bytes
        var cells1 = SIMD32<UInt16>()
    }
    static var zeroBoardStorage: BoardStorage { BoardStorage() }
    static let allTrueCellStorage: UInt16 = 0b111111111
    static var sideOfBox: Int { 3 }
    static let solvedRepresentation = (1...9).map(String.init)
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku16: SudokuTypeProtocol {
    typealias CellStorage = UInt16
    typealias CellIteratorStorage = Int32
    struct BoardStorage: Hashable, Sendable {
        var cells0 = SIMD64<UInt16>() // 512 bytes = 256 cells × 2 bytes
        var cells1 = SIMD64<UInt16>()
        var cells2 = SIMD64<UInt16>()
        var cells3 = SIMD64<UInt16>()
    }
    static var zeroBoardStorage: BoardStorage { BoardStorage() }
    static let allTrueCellStorage: UInt16 = 0b11111111_11111111
    static var sideOfBox: Int { 4 }
    static let solvedRepresentation = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku25: SudokuTypeProtocol {
    typealias CellStorage = UInt32
    typealias CellIteratorStorage = Int32
    struct BoardStorage: Hashable, Sendable {
        var cells0 = SIMD64<UInt32>() // 2560 bytes ≥ 625 cells × 4 bytes
        var cells1 = SIMD64<UInt32>()
        var cells2 = SIMD64<UInt32>()
        var cells3 = SIMD64<UInt32>()
        var cells4 = SIMD64<UInt32>()
        var cells5 = SIMD64<UInt32>()
        var cells6 = SIMD64<UInt32>()
        var cells7 = SIMD64<UInt32>()
        var cells8 = SIMD64<UInt32>()
        var cells9 = SIMD64<UInt32>()
    }
    static var zeroBoardStorage: BoardStorage { BoardStorage() }
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
