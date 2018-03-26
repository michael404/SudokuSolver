struct OneToNineSet: Sequence {
    
    /// Bits 0 through 3 contains 0 if this set has a count higher than one
    /// and the only value if it only has one value. Bits 6 through 14 contains
    /// the bit set info for numbers 1 to 9. Bits 4, 5 and 15 are padding and should always
    /// be set to 0
    private var _storage: UInt16
    
    private var _onlyValue: UInt16 {
        return _storage >> 12
    }
    
    //Precondition: Can only be set if _onlyValue is 0
    private mutating func setOnlyValue(to value: UInt16) {
        _storage = _storage | (value << 12)
    }
    
    init(allTrue: ()) {
        self._storage = 0b0000001111111110
    }
    
    init(_ value: Int) {
        assert((1...9).contains(value))
        self._storage = 1 << value ^ 0
        setOnlyValue(to: UInt16(truncatingIfNeeded: value))
    }
    
    func contains(_ value: Int) -> Bool {
        assert((1...9).contains(value))
        return ((_storage >> value) & 1) == 1
    }
    
    //Returns true if a value was removed
    mutating func remove(_ value: Int) -> Bool {
        assert((1...9).contains(value))
        let oldValue = ((_storage >> value) & 1) == 1
        if oldValue {
            _storage = 1 << value ^ _storage
            if hasSingeValue {
                for index in 1...9 where contains(index) {
                    setOnlyValue(to: UInt16(truncatingIfNeeded: index))
                }
            }
            return true
        }
        return false
    }
    
    var count: Int {
        guard !hasSingeValue else { return 1 }
        // Borrowed from http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSet64
        return (Int(truncatingIfNeeded: _storage) * 0x200040008001 & 0x111111111111111) % 0xf
    }
    
    var hasSingeValue: Bool {
        return _onlyValue != 0
    }

    var onlyValue: Int? {
        guard _onlyValue != 0 else { return nil }
        return Int(truncatingIfNeeded: _onlyValue)
    }
    
    func makeIterator() -> OneToNineIterator {
        return OneToNineIterator(self)
    }
}

struct OneToNineIterator: IteratorProtocol {
    
    var base: OneToNineSet
    private var index = 1
    
    init(_ base: OneToNineSet) { self.base = base }
    
    mutating func next() -> Int? {
        
        guard index < 10 else { return nil }
        
        if base.hasSingeValue {
            index = 10
            return base.onlyValue
        }
        
        repeat {
            defer { index = index &+ 1 }
            if base.contains(index) { return index }
        } while index < 10
        return nil
        
    }
    
}

