struct OneToNineSet: Equatable {
    
    /// Bits 7 through 15 contains  the bit set info for numbers 1 to 9.
    /// Bits 0 to 6 are padding and should always be set to 0.
    /// The set is considered "solved" if only one bit is set.
    fileprivate var _storage: UInt16
    
    init(allTrue: ()) {
        self._storage = 0b0000001111111110
    }
    
    init(from value: Int) {
        assert((1...9).contains(value))
        self._storage = 1 << value
    }
    
    init(bitPattern: UInt16) {
        self._storage = bitPattern
    }
    
    var count: Int {
        // Borrowed from http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSet64
        return (Int(truncatingIfNeeded: _storage) * 0x200040008001 & 0x111111111111111) % 0xf
    }
    
    var isSolved: Bool {
        // Borrowed from http://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
        // Note that 0 is incorrectly considered a power of 2, but that does not matter in this context
        return (_storage & (_storage - 1)) == 0
    }
    
    var solvedValue: OneToNineSet? {
        return isSolved ? self : nil
    }
    
    func contains(_ value: OneToNineSet) -> Bool {
        return (_storage & value._storage) != 0
    }
    
    /// Returns true if a value was removed
    /// Throws if the last value was removed
    mutating func remove(_ value: OneToNineSet) -> Bool {
        guard contains(value) else { return false }
        _storage = _storage & ~value._storage
        return true
    }
    
}

extension OneToNineSet: Sequence{
    
    func makeIterator() -> OneToNineSetIterator {
        return OneToNineSetIterator(self)
    }
}

struct OneToNineSetIterator: IteratorProtocol {
    
    var base: OneToNineSet
    private var mask = OneToNineSet(from: 1)
    
    init(_ base: OneToNineSet) { self.base = base }
    
    mutating func next() -> OneToNineSet? {
        
        while mask._storage != 0b10000000000 {
            defer { mask._storage = mask._storage << 1 }
            if base.contains(mask) { return mask }
        }
        
        return nil
        
    }
    
}

// For testing
extension OneToNineSet: ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        self.init(from: value)
    }
    
}

extension Int {
    
    init(_ set: OneToNineSet) {
        switch set._storage {
        case 0b1000000000: self = 9
        case 0b100000000: self = 8
        case 0b10000000: self = 7
        case 0b1000000: self = 6
        case 0b100000: self = 5
        case 0b10000: self = 4
        case 0b1000: self = 3
        case 0b100: self = 2
        case 0b10: self = 1
        default: preconditionFailure()
        }
    }
}
