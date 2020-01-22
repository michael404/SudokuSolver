/// A type representing a Sudoku cell with a set a set of all the
/// possible values the cell could have (1 through 9).
/// The implementation uses a bit array as the underlying storage.
/// A solved value is represented with the same type, but with only
/// one bit set.
struct SudokuCell16: Hashable {
    
    /// A bitset representing the 16 possible values.
    /// The set is considered "solved" if only one bit is set.
    fileprivate(set) var storage: UInt16
    
    static let allTrue: SudokuCell16 = SudokuCell16(storage: UInt16.max)
    
    private init(storage: UInt16) {
        self.storage = storage
    }
    
    init(solved value: Int) {
        assert((0..<16).contains(value))
        self.storage = 1 << value
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

extension SudokuCell16: BidirectionalCollection {
    
    enum Index: Comparable {
        case index(SudokuCell16)
        case end
        
        static func < (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case (.end, _): return false
            case (.index, .end): return true
            case let (.index(i1), .index(i2)): return i1.storage < i2.storage
            }
        }
        
    }
    
    var startIndex: Index { .index(SudokuCell16(storage: 1 << self.storage.trailingZeroBitCount)) }
    var endIndex: Index { .end }
    
    func index(after i: Index) -> Index {
        switch i {
        case .end:
            fatalError("Tried to advance beyond endIndex")
        case .index(var cell):
            assert(cell.count == 1)
            while cell != SudokuCell16(solved: 15) {
                cell.storage <<= 1
                if self.contains(cell) { return .index(cell) }
            }
            return endIndex
        }
    }
    
    func index(before i: Index) -> Index {
        
        func _before(cell: SudokuCell16) -> Index {
            var cell = cell
            while cell != SudokuCell16(solved: 1) {
                cell.storage >>= 1
                if self.contains(cell) { return .index(cell) }
            }
            return startIndex
        }
        
        switch i {
        case startIndex:
            fatalError("Tried to advance before startIndex")
        case .end where self.contains(SudokuCell16(solved: 15)):
            return .index(SudokuCell16(solved: 15))
        case .end:
            return _before(cell: SudokuCell16(solved: 15))
        case .index(let cell):
            assert(cell.count == 1)
            return _before(cell: cell)
        }

    }
    
    subscript(i: Index) -> SudokuCell16 {
        switch i {
        case .end: fatalError("Subscripted with .end")
        case .index(let i):
            assert(i.count == 1)
            assert(self.contains(i), "Tried to subscript with \(i) in cell which contains only \(map { $0.description })")
            return i
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
