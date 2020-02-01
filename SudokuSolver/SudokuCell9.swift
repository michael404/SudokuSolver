/// A type representing a Sudoku cell with a set a set of all the
/// possible values the cell could have (1 through 9).
/// The implementation uses a bit array as the underlying storage.
/// A solved value is represented with the same type, but with only
/// one bit set.
struct SudokuCell9: SudokuCellProtocol {
    
    typealias Storage = UInt16
    typealias IteratorStorage = Int16
    
    /// The lowest 9 bits  contains the bit set info for numbers 1 to 9.
    /// The higest 7 bits are padding and should always be set to 0.
    /// The set is considered "solved" if only one bit is set.
    var storage: UInt16
    
    static let allTrue: SudokuCell9 = SudokuCell9(storage: 0b111111111)
    
    init(storage: UInt16) {
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
