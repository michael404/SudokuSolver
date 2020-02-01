/// A type representing a Sudoku cell with a set a set of all the
/// possible values the cell could have (1 through 9).
/// The implementation uses a bit array as the underlying storage.
/// A solved value is represented with the same type, but with only
/// one bit set.
struct SudokuCell9: SudokuCellProtocol {
    
    /// The lowest 9 bits  contains the bit set info for numbers 1 to 9.
    /// The higest 7 bits are padding and should always be set to 0.
    /// The set is considered "solved" if only one bit is set.
    fileprivate(set) var storage: UInt16
    
    static let allTrue: SudokuCell9 = SudokuCell9(storage: 0b111111111)
    
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
    
    var solvedValue: SudokuCell9? { isSolved ? self : nil }
    
    func contains(_ value: SudokuCell9) -> Bool { (storage & value.storage) != 0 }
    
    /// Returns true if a value was removed
    /// Throws if the last value was removed
    /// This method supports removing multiple values at a time
    mutating func remove(_ value: SudokuCell9) throws -> Bool {
        let original = self
        self.storage &= ~value.storage
        if self.storage == 0 { throw SudokuSolverError.unsolvable }
        return self != original
    }
    
}

// Needed to be able to use SudokuCell as its own index type
extension SudokuCell9: Comparable {
    static func < (lhs: SudokuCell9, rhs: SudokuCell9) -> Bool {
        lhs.storage < rhs.storage
    }
}

extension SudokuCell9: Sequence {
    
    func makeIterator() -> Iterator { Iterator(self) }
    
    struct Iterator: IteratorProtocol {

        private var remaining: Int16
        
        init(_ cell: SudokuCell9) {
            self.remaining = Int16(truncatingIfNeeded: cell.storage)
        }
        
        mutating func next() -> SudokuCell9? {
            guard remaining != 0 else { return nil }
            let lowestBitSet = remaining & -remaining
            self.remaining ^= lowestBitSet
            return SudokuCell9(storage: UInt16(truncatingIfNeeded: lowestBitSet))
        }
        
    }
    
}

extension SudokuCell9: BidirectionalSequence {
    
    func makeReverseSequence() -> ReverseSequence { ReverseSequence(cell: self) }
    
    struct ReverseSequence: Sequence {
        
        let cell: SudokuCell9
        
        func makeIterator() -> Iterator { Iterator(cell) }
        
        struct Iterator: IteratorProtocol {
            
            private var remaining: Int16
            
            init(_ cell: SudokuCell9) {
                self.remaining = Int16(truncatingIfNeeded: cell.storage)
            }
            
            mutating func next() -> SudokuCell9? {
                guard remaining != 0 else { return nil }
                let highestSetBit = remaining.highestSetBit
                self.remaining ^= highestSetBit
                return SudokuCell9(storage: UInt16(truncatingIfNeeded: highestSetBit))
            }
            
        }
        
    }
    
}

extension SudokuCell9: CustomStringConvertible {
    var description: String { isSolved ? String(Int(self)) : " " }
}

extension SudokuCell9: CustomDebugStringConvertible {
    var debugDescription: String { isSolved ? String(Int(self)) : "." }
}

extension SudokuCell9: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.init(solved: value)
    }
}


extension Int {
    
    init(_ value: SudokuCell9) {
        precondition(value.isSolved, "Int must be initialized with a solved value")
        self = value.storage.trailingZeroBitCount + 1
    }
}
