protocol SudokuTypeProtocol: Sendable {
    associatedtype CellStorage: BinaryInteger & FixedWidthInteger & Sendable
    associatedtype CellIteratorStorage: SignedInteger & FixedWidthInteger & Sendable
    /// The smallest unsigned integer type that holds any cell index of this board
    /// size. The precomputed index tables store this type to stay compact.
    associatedtype IndexStorage: FixedWidthInteger & UnsignedInteger & Sendable
    /// Fixed-size inline storage for all cells of a board, so that copying a board is
    /// a flat memcpy with no heap allocation, reference counting or copy-on-write
    /// checks. Must be at least `cells * CellStorage` bytes. `SudokuBoard` reinterprets
    /// the raw bytes as cells and keeps any trailing padding zeroed, so the synthesized
    /// equality of this type matches cell-wise equality.
    ///
    /// TODO: Replace the SIMD-backed storage structs with `InlineArray<cells, CellStorage>`
    /// once the project can target macOS 26. That removes the raw-byte reinterpretation,
    /// and InlineArray's first-class borrow semantics should let the fast mutating
    /// accessors on `SudokuBoard` collapse back into the Collection subscript.
    associatedtype BoardStorage: Hashable & Sendable
    static var zeroBoardStorage: BoardStorage { get }
    /// Fixed-size inline storage holding one byte per cell. The solver keeps a
    /// mirror of each cell's candidate count in this, updated incrementally where
    /// counts change, so the guess-cell selection scan reads dense bytes instead
    /// of loading and popcounting every cell.
    associatedtype CountsStorage: Sendable
    static var zeroCountsStorage: CountsStorage { get }
    static var allTrueCellStorage: CellStorage { get }
    static var sideOfBox: Int { get }
    /// Whether the solver runs the claiming (line-to-box locked candidates) sweep.
    /// It pays for itself only on boards where backtracking dominates: measured
    /// 1.4-1.7x on 25×25, but a 10-30% slowdown on 9×9 and 16×16, where the
    /// puzzles are deduction-dominated and the extra sweep rarely fires.
    static var usesClaimedCandidates: Bool { get }
    /// Whether the solver runs the hidden-pairs sweep (two values confined to the
    /// same two cells of a unit restrict those cells to exactly those values).
    /// Like claiming, only worth its per-guess cost on search-dominated boards.
    static var usesHiddenPairs: Bool { get }
    /// Whether the solver runs the naked-triples sweep (three cells of a unit
    /// whose combined candidates are exactly three values exclude those values
    /// from the unit's other cells).
    static var usesNakedTriples: Bool { get }
    /// Whether the hidden-pairs sweep also looks for hidden triples (three values
    /// jointly confined to three cells of a unit). Reuses the pairs sweep's
    /// position masks, so it can only be enabled where `usesHiddenPairs` is.
    static var usesHiddenTriples: Bool { get }
    static var solvedRepresentation: [String] { get }
    /// Maps each symbol in `solvedRepresentation` back to its value.
    /// Stored per conforming type so it is built once, not on every lookup.
    static var solvedRepresentationReversed: [String: Int] { get }
    static var constants: ConstantsStorage<Self> { get }
}

extension SudokuTypeProtocol {
    static var usesClaimedCandidates: Bool { false }
    static var usesHiddenPairs: Bool { false }
    static var usesNakedTriples: Bool { false }
    static var usesHiddenTriples: Bool { false }
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
    typealias IndexStorage = UInt8 // 16 cells
    struct BoardStorage: Hashable, Sendable {
        var cells0 = SIMD16<UInt8>() // 16 bytes ≥ 16 cells × 1 byte
    }
    static var zeroBoardStorage: BoardStorage { BoardStorage() }
    struct CountsStorage: Sendable {
        var counts0 = SIMD16<UInt8>() // 16 bytes ≥ 16 cells
    }
    static var zeroCountsStorage: CountsStorage { CountsStorage() }
    static let allTrueCellStorage: UInt8 = 0b1111
    static var sideOfBox: Int { 2 }
    static let solvedRepresentation = (1...4).map(String.init)
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku9: SudokuTypeProtocol {
    typealias CellStorage = UInt16
    typealias CellIteratorStorage = Int16
    typealias IndexStorage = UInt8 // 81 cells
    struct BoardStorage: Hashable, Sendable {
        var cells0 = SIMD64<UInt16>() // 192 bytes ≥ 81 cells × 2 bytes
        var cells1 = SIMD32<UInt16>()
    }
    static var zeroBoardStorage: BoardStorage { BoardStorage() }
    struct CountsStorage: Sendable {
        var counts0 = SIMD64<UInt8>() // 96 bytes ≥ 81 cells
        var counts1 = SIMD32<UInt8>()
    }
    static var zeroCountsStorage: CountsStorage { CountsStorage() }
    static let allTrueCellStorage: UInt16 = 0b111111111
    static var sideOfBox: Int { 3 }
    static let solvedRepresentation = (1...9).map(String.init)
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku16: SudokuTypeProtocol {
    typealias CellStorage = UInt16
    typealias CellIteratorStorage = Int32
    typealias IndexStorage = UInt8 // 256 cells: indices 0-255 fit exactly
    struct BoardStorage: Hashable, Sendable {
        var cells0 = SIMD64<UInt16>() // 512 bytes = 256 cells × 2 bytes
        var cells1 = SIMD64<UInt16>()
        var cells2 = SIMD64<UInt16>()
        var cells3 = SIMD64<UInt16>()
    }
    static var zeroBoardStorage: BoardStorage { BoardStorage() }
    struct CountsStorage: Sendable {
        var counts0 = SIMD64<UInt8>() // 256 bytes = 256 cells
        var counts1 = SIMD64<UInt8>()
        var counts2 = SIMD64<UInt8>()
        var counts3 = SIMD64<UInt8>()
    }
    static var zeroCountsStorage: CountsStorage { CountsStorage() }
    static let allTrueCellStorage: UInt16 = 0b11111111_11111111
    static var sideOfBox: Int { 4 }
    static let solvedRepresentation = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku25: SudokuTypeProtocol {
    typealias CellStorage = UInt32
    typealias CellIteratorStorage = Int32
    typealias IndexStorage = UInt16 // 625 cells
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
    struct CountsStorage: Sendable {
        var counts0 = SIMD64<UInt8>() // 640 bytes ≥ 625 cells
        var counts1 = SIMD64<UInt8>()
        var counts2 = SIMD64<UInt8>()
        var counts3 = SIMD64<UInt8>()
        var counts4 = SIMD64<UInt8>()
        var counts5 = SIMD64<UInt8>()
        var counts6 = SIMD64<UInt8>()
        var counts7 = SIMD64<UInt8>()
        var counts8 = SIMD64<UInt8>()
        var counts9 = SIMD64<UInt8>()
    }
    static var zeroCountsStorage: CountsStorage { CountsStorage() }
    static let allTrueCellStorage: UInt32 = 0b11111_11111_11111_11111_11111
    static var sideOfBox: Int { 5 }
    static var usesClaimedCandidates: Bool { true }
    static var usesHiddenPairs: Bool { false } // measured: -29% uniqueness, -3x end-to-end
    static var usesNakedTriples: Bool { true }
    static let solvedRepresentation = (65...89).map { String(UnicodeScalar($0)) } // "A"..."Y"
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

enum Sudoku36: SudokuTypeProtocol {
    typealias CellStorage = UInt64
    typealias CellIteratorStorage = Int64
    typealias IndexStorage = UInt16 // 1296 cells
    struct BoardStorage: Hashable, Sendable {
        var cells0 = SIMD64<UInt64>() // 21 × 512 bytes ≥ 1296 cells × 8 bytes
        var cells1 = SIMD64<UInt64>()
        var cells2 = SIMD64<UInt64>()
        var cells3 = SIMD64<UInt64>()
        var cells4 = SIMD64<UInt64>()
        var cells5 = SIMD64<UInt64>()
        var cells6 = SIMD64<UInt64>()
        var cells7 = SIMD64<UInt64>()
        var cells8 = SIMD64<UInt64>()
        var cells9 = SIMD64<UInt64>()
        var cells10 = SIMD64<UInt64>()
        var cells11 = SIMD64<UInt64>()
        var cells12 = SIMD64<UInt64>()
        var cells13 = SIMD64<UInt64>()
        var cells14 = SIMD64<UInt64>()
        var cells15 = SIMD64<UInt64>()
        var cells16 = SIMD64<UInt64>()
        var cells17 = SIMD64<UInt64>()
        var cells18 = SIMD64<UInt64>()
        var cells19 = SIMD64<UInt64>()
        var cells20 = SIMD64<UInt64>()
    }
    static var zeroBoardStorage: BoardStorage { BoardStorage() }
    struct CountsStorage: Sendable {
        var counts0 = SIMD64<UInt8>() // 21 × 64 bytes ≥ 1296 cells
        var counts1 = SIMD64<UInt8>()
        var counts2 = SIMD64<UInt8>()
        var counts3 = SIMD64<UInt8>()
        var counts4 = SIMD64<UInt8>()
        var counts5 = SIMD64<UInt8>()
        var counts6 = SIMD64<UInt8>()
        var counts7 = SIMD64<UInt8>()
        var counts8 = SIMD64<UInt8>()
        var counts9 = SIMD64<UInt8>()
        var counts10 = SIMD64<UInt8>()
        var counts11 = SIMD64<UInt8>()
        var counts12 = SIMD64<UInt8>()
        var counts13 = SIMD64<UInt8>()
        var counts14 = SIMD64<UInt8>()
        var counts15 = SIMD64<UInt8>()
        var counts16 = SIMD64<UInt8>()
        var counts17 = SIMD64<UInt8>()
        var counts18 = SIMD64<UInt8>()
        var counts19 = SIMD64<UInt8>()
        var counts20 = SIMD64<UInt8>()
    }
    static var zeroCountsStorage: CountsStorage { CountsStorage() }
    static let allTrueCellStorage: UInt64 = (1 << 36) - 1
    static var sideOfBox: Int { 6 }
    static var usesClaimedCandidates: Bool { true }
    static var usesHiddenPairs: Bool { true }
    static var usesNakedTriples: Bool { true }
    static var usesHiddenTriples: Bool { true }
    static let solvedRepresentation = (0...9).map(String.init) + (65...90).map { String(UnicodeScalar($0)) } // 0-9, A-Z
    static let solvedRepresentationReversed = makeSolvedRepresentationReversed()
    static let constants: ConstantsStorage<Self> = ConstantsStorage()
}

typealias SudokuBoard4 = SudokuBoard<Sudoku4>
typealias SudokuBoard9 = SudokuBoard<Sudoku9>
typealias SudokuBoard16 = SudokuBoard<Sudoku16>
typealias SudokuBoard25 = SudokuBoard<Sudoku25>
typealias SudokuBoard36 = SudokuBoard<Sudoku36>

typealias SudokuCell4 = SudokuCell<Sudoku4>
typealias SudokuCell9 = SudokuCell<Sudoku9>
typealias SudokuCell16 = SudokuCell<Sudoku16>
typealias SudokuCell25 = SudokuCell<Sudoku25>
typealias SudokuCell36 = SudokuCell<Sudoku36>
