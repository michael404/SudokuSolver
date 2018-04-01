/// A struct representing a Sudoku cell with a set a set of all the
/// possible values the cell could have (1 through 9).
/// The implementation uses a bit array as the underlying storage.
/// When only one bit is set, the cell is considered solved.
/// A solved set is represented by the same type
struct PossibleCellValues: Equatable {
    
    /// Bits 7 through 15 contains  the bit set info for numbers 1 to 9.
    /// Bits 0 to 6 are padding and should always be set to 0.
    /// The set is considered "solved" if only one bit is set.
    fileprivate var _storage: UInt16
    
    init(allTrue: ()) {
        self._storage = 0b0000001111111110
    }
    
    init(solved value: Int) {
        assert((1...9).contains(value))
        self._storage = 1 << value
    }
    
    init(bitPattern: UInt16) {
        self._storage = bitPattern
    }
    
    var count: Int {
        // Borrowed from http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSet64
        return (numericCast(_storage) * 0x200040008001 & 0x111111111111111) % 0xf
    }
    
    var isSolved: Bool {
        // Borrowed from http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
        // Note that 0 is incorrectly considered a power of 2, but that does not matter in this context
        // since _storage should never be 0
        return (_storage & (_storage - 1)) == 0
    }
    
    var solvedValue: PossibleCellValues? {
        return isSolved ? self : nil
    }
    
    func contains(_ value: PossibleCellValues) -> Bool {
        return (_storage & value._storage) != 0
    }
    
    /// Returns true if a value was removed
    /// Throws if the last value was removed
    mutating func remove(_ value: PossibleCellValues) throws -> Bool {
        
        if solvedValue == value {
            //Tried to remove the value that was filled
            throw SudokuSolverError.unsolvable
        }
        
        guard contains(value) else { return false }
        
        _storage = _storage & ~value._storage
        return true
    }
    
}

extension PossibleCellValues: Sequence{
    
    func makeIterator() -> PossibleCellValuesIterator {
        return PossibleCellValuesIterator(self)
    }
}

struct PossibleCellValuesIterator: IteratorProtocol {
    
    var base: PossibleCellValues
    private var mask = PossibleCellValues(solved: 1)
    
    init(_ base: PossibleCellValues) { self.base = base }
    
    mutating func next() -> PossibleCellValues? {
        
        while mask._storage != 0b10000000000 {
            defer { mask._storage = mask._storage << 1 }
            if base.contains(mask) { return mask }
        }
        
        return nil
    }
    
}

// For testing
extension PossibleCellValues: ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        self.init(solved: value)
    }
    
}

extension SudokuCell {
    
    init(_ set: PossibleCellValues) {
        switch set._storage {
        case 0b10:         self.init(1)
        case 0b100:        self.init(2)
        case 0b1000:       self.init(3)
        case 0b10000:      self.init(4)
        case 0b100000:     self.init(5)
        case 0b1000000:    self.init(6)
        case 0b10000000:   self.init(7)
        case 0b100000000:  self.init(8)
        case 0b1000000000: self.init(9)
        default:           preconditionFailure()
        }
    }
}
