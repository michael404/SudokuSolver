/// A type representing a Sudoku cell with a set a set of all the
/// possible values the cell could have (1 through 9).
/// The implementation uses a bit array as the underlying storage.
/// A solved value is represented with the same type, but with only
/// one bit set.
struct SudokuCell: Hashable {
    
    /// Bits 7 through 15 contains  the bit set info for numbers 1 to 9.
    /// Bits 0 to 6 are padding and should always be set to 0.
    /// The set is considered "solved" if only one bit is set.
    fileprivate var storage: UInt16
    
    static let allTrue: SudokuCell = SudokuCell(allTrue: ())
    private init(allTrue: ()) { self.storage = 0b0000001111111110 }
    
    init(solved value: Int) {
        assert((1...9).contains(value))
        self.storage = 0b1 << value
    }
    
    var count: Int {
        // Borrowed from http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSet64
        // While `storage.nonzeroBitCount` should be mapped to SSE instructions, it seems to
        // be a little bit slower
        return (numericCast(storage) * 0x200040008001 & 0x111111111111111) % 0xf
    }
    
    var isSolved: Bool {
        // Borrowed from http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
        // Note that 0 is incorrectly considered a power of 2, but that does not matter in this context
        // since _storage should never be 0
        return (storage & (storage - 1)) == 0
    }
    
    var solvedValue: SudokuCell? {
        return isSolved ? self : nil
    }
    
    func contains(_ value: SudokuCell) -> Bool {
        return (storage & value.storage) != 0
    }
    
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
    
    func makeIterator() -> SudokuCellIterator {
        return SudokuCellIterator(self)
    }
}

struct SudokuCellIterator: IteratorProtocol, Sequence {
    
    var base: SudokuCell
    private var mask = SudokuCell(solved: 1)
    
    init(_ base: SudokuCell) { self.base = base }
    
    mutating func next() -> SudokuCell? {
        while mask.storage != 0b10000000000 {
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
        while mask.storage != 0b1 {
            defer { mask.storage >>= 1 }
            if base.contains(mask) { return mask }
        }
        return nil
    }
    
}

extension SudokuCell: CustomStringConvertible {
    var description: String {
        return isSolved ? String(Int(self)) : " "
    }
}

extension SudokuCell: CustomDebugStringConvertible {
    var debugDescription: String {
        return isSolved ? String(Int(self)) : "."
    }
}

extension SudokuCell: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.init(solved: value)
    }
}


extension Int {
    
    init(_ value: SudokuCell) {
        switch value.storage {
        case 0b10:         self.init(1)
        case 0b100:        self.init(2)
        case 0b1000:       self.init(3)
        case 0b10000:      self.init(4)
        case 0b100000:     self.init(5)
        case 0b1000000:    self.init(6)
        case 0b10000000:   self.init(7)
        case 0b100000000:  self.init(8)
        case 0b1000000000: self.init(9)
        default: preconditionFailure()
        }
    }
}
