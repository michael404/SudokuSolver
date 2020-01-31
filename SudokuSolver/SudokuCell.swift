/// A type representing a Sudoku cell with a set a set of all the
/// possible values the cell could have (1 through 9).
/// The implementation uses a bit array as the underlying storage.
/// A solved value is represented with the same type, but with only
/// one bit set.
struct SudokuCell: SudokuCellProtocol {
    
    /// The lowest 9 bits  contains the bit set info for numbers 1 to 9.
    /// The higest 7 bits are padding and should always be set to 0.
    /// The set is considered "solved" if only one bit is set.
    fileprivate(set) var storage: UInt16
    
    static let allTrue: SudokuCell = SudokuCell(storage: 0b111111111)
    
    private init(storage: UInt16) {
        self.storage = storage
    }
    
    init(solved value: Int) {
        assert((1...9).contains(value))
        self.storage = 1 << (value - 1) as UInt16
    }
    
    init(character: Character) {
        switch character {
        case ".": self = Self.allTrue
        case "1"..."9": self = Self(solved: Int(String(character))!)
        default: preconditionFailure("Unexpected character \(character) in string sequence")
        }
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

// Needed to be able to use SudokuCell as its own index type
extension SudokuCell: Comparable {
    static func < (lhs: SudokuCell, rhs: SudokuCell) -> Bool {
        lhs.storage < rhs.storage
    }
}

extension SudokuCell: BidirectionalCollection {
    
    var startIndex: SudokuCell { SudokuCell(storage: 1 << self.storage.trailingZeroBitCount) }
    var endIndex: SudokuCell { SudokuCell(storage: 1 << 10) }
    
    func index(after i: SudokuCell) -> SudokuCell {
        assert(i.count == 1)
        assert(i != endIndex)
        var i = i
        while i != endIndex {
            i.storage <<= 1
            if self.contains(i) { return i }
        }
        return endIndex
    }
    
    func index(before i: SudokuCell) -> SudokuCell {
        assert(i.count == 1)
        assert(i != startIndex)
        var i = i
        while i != startIndex {
            i.storage >>= 1
            if self.contains(i) { return i }
        }
        return startIndex

    }
    
    subscript(i: SudokuCell) -> SudokuCell {
        assert(i.count == 1)
        assert(self.contains(i))
        return i
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
