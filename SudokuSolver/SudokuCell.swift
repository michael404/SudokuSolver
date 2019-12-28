/// A type representing a Sudoku cell with a set a set of all the
/// possible values the cell could have (1 through 9).
/// The implementation uses a bit array as the underlying storage.
/// A solved value is represented with the same type, but with only
/// one bit set.
struct SudokuCell: Hashable {
    
    /// Bits 7 through 15 contains  the bit set info for numbers 1 to 9.
    /// Bits 0 through 6  are padding and should always be set to 0.
    /// The set is considered "solved" if only one bit is set.
    fileprivate(set) var storage: UInt16
    
    static let allTrue: SudokuCell = SudokuCell(allTrue: ())
    private init(allTrue: ()) { self.storage = 0b111111111 }
    
    init(solved value: Int) {
        assert((1...9).contains(value))
        self.storage = 0b1 << (value - 1) as UInt16
    }
    
    /// The number of possible values for this cell
    var count: Int { storage.nonzeroBitCount }
    
    var isSolved: Bool { storage.nonzeroBitCount == 1 }
    
    var solvedValue: SudokuCell? { isSolved ? self : nil }
    
    func contains(_ value: SudokuCell) -> Bool { (storage & value.storage) != 0 }
    
    /// Returns true if a value was removed
    /// Throws if the last value was removed
    /// This method supports removing multiple values at a time
    mutating func remove(_ value: SudokuCell) throws -> Bool {
        let original = self
        self.storage &= ~value.storage
        if self.storage == 0 { throw SudokuSolverError.unsolvable }
        return self != original
    }
    
}

extension SudokuCell: Sequence {
    
    func makeIterator() -> SudokuCellIterator { SudokuCellIterator(self) }
}

struct SudokuCellIterator: IteratorProtocol, Sequence {
    
    var base: SudokuCell
    private var mask = SudokuCell(solved: 1)
    
    init(_ base: SudokuCell) { self.base = base }
    
    mutating func next() -> SudokuCell? {
        while mask.storage != 0b1000000000 {
            defer { mask.storage <<= 1 }
            if base.contains(mask) { return mask }
        }
        return nil
    }
    
}

struct SudokuCellReversedIterator: IteratorProtocol, Sequence {
    
    var base: SudokuCell
    private var mask = SudokuCell(solved: 9)
    
    init(_ base: SudokuCell) { self.base = base }
    
    mutating func next() -> SudokuCell? {
        while mask.storage != 0 {
            defer { mask.storage >>= 1 }
            if base.contains(mask) { return mask }
        }
        return nil
    }
    
}

extension SudokuCell: CustomStringConvertible {
    var description: String { isSolved ? String(Int(self)) : " " }
}

extension SudokuCell: CustomDebugStringConvertible {
    var debugDescription: String { isSolved ? String(Int(self)) : "." }
}

extension SudokuCell: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.init(solved: value)
    }
}


extension Int {
    
    init(_ value: SudokuCell) {
        precondition(value.isSolved, "Int must be initialized with a solved value")
        self = value.storage.trailingZeroBitCount + 1
    }
}
