/// A type representing a Sudoku cell with a set a set of all the
/// possible values the cell could have (1 through 9).
/// The implementation uses a bit array as the underlying storage.
/// A solved value is represented with the same type, but with only
/// one bit set.
struct SudokuCell16: SudokuCellProtocol {
    
    /// A bitset representing the 16 possible values.
    /// The set is considered "solved" if only one bit is set.
    fileprivate(set) var storage: UInt16
    
    static let allTrue: SudokuCell16 = SudokuCell16(storage: UInt16.max)
    
    private init(storage: UInt16) {
        self.storage = storage
    }
    
    init(solved value: Int) {
        assert((0..<16).contains(value), "\(value) is not a valid value")
        self.storage = 1 << value
    }
    
    init(character: Character) {
        switch character {
        case ".": self = Self.allTrue
        case "0"..."9": self = Self(solved: Int(String(character))!)
        case "A": self = Self(solved: 10)
        case "B": self = Self(solved: 11)
        case "C": self = Self(solved: 12)
        case "D": self = Self(solved: 13)
        case "E": self = Self(solved: 14)
        case "F": self = Self(solved: 15)
        default: preconditionFailure("Unexpected character \(character) in string sequence")
        }
    }
    
    /// The number of possible values for this cell
    var count: Int { storage.nonzeroBitCount }
    
    var isSolved: Bool { storage.nonzeroBitCount == 1 }
    
    var solvedValue: SudokuCell16? { isSolved ? self : nil }
    
    func contains(_ value: SudokuCell16) -> Bool { (storage & value.storage) != 0 }
    
    /// Returns true if a value was removed
    /// Throws if the last value was removed
    /// This method supports removing multiple values at a time
    mutating func remove(_ value: SudokuCell16) throws -> Bool {
        let original = self
        self.storage &= ~value.storage
        if self.storage == 0 { throw SudokuSolverError.unsolvable }
        return self != original
    }
    
}

extension SudokuCell16: Sequence {
    
    func makeIterator() -> Iterator { Iterator(self) }
    
    struct Iterator: IteratorProtocol {

        private var remaining: Int32
        
        init(_ cell: SudokuCell16) {
            self.remaining = Int32(truncatingIfNeeded: cell.storage)
        }
        
        mutating func next() -> SudokuCell16? {
            guard remaining != 0 else { return nil }
            let lowestBitSet = remaining & -remaining
            self.remaining ^= lowestBitSet
            return SudokuCell16(storage: UInt16(truncatingIfNeeded: lowestBitSet))
        }
        
    }

}

extension SudokuCell16: BidirectionalSequence {
    
    func makeReverseSequence() -> ReverseSequence { ReverseSequence(cell: self) }
    
    struct ReverseSequence: Sequence {
        
        let cell: SudokuCell16
        
        func makeIterator() -> Iterator { Iterator(cell) }
        
        struct Iterator: IteratorProtocol {
            
            private var remaining: Int32
            
            init(_ cell: SudokuCell16) {
                self.remaining = Int32(truncatingIfNeeded: cell.storage)
            }
            
            mutating func next() -> SudokuCell16? {
                guard remaining != 0 else { return nil }
                let highestSetBit = remaining.highestSetBit
                self.remaining ^= highestSetBit
                return SudokuCell16(storage: UInt16(truncatingIfNeeded: highestSetBit))
            }
            
        }
        
    }
    
}

extension SudokuCell16: CustomStringConvertible {
    var description: String { isSolved ? String(Character(self)) : " " }
}

extension SudokuCell16: CustomDebugStringConvertible {
    var debugDescription: String { isSolved ? String(Character(self)) : "." }
}

extension SudokuCell16: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.init(solved: value)
    }
}


extension Int {
    
    init(_ value: SudokuCell16) {
        precondition(value.isSolved, "Int must be initialized with a solved value")
        self = value.storage.trailingZeroBitCount
    }
}

extension Character {
    
    init(_ value: SudokuCell16) {
        let int = Int(value)
        switch int {
        case 0...9: self = Character(int.description)
        case 10: self = "A"
        case 11: self = "B"
        case 12: self = "C"
        case 13: self = "D"
        case 14: self = "E"
        case 15: self = "F"
        default: fatalError("Could not convert SudokuCell16 with storage to Character")
        }
    }
    
}
