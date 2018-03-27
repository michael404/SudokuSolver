struct OneToNineSet {
    
    /// Bits 0 through 3 contains 0 if this set has a count higher than one
    /// and the solved value if it only has one value. Bits 6 through 14 contains
    /// the bit set info for numbers 1 to 9. Bits 4, 5 and 15 are padding and should always
    /// be set to 0
    private var _storage: UInt16
    
    private var _solvedValue: UInt16 {
        return _storage >> 12
    }
    
    var isSolved: Bool {
        return _solvedValue != 0
    }
    
    var solvedValue: Int? {
        guard _solvedValue != 0 else { return nil }
        return Int(truncatingIfNeeded: _solvedValue)
    }
    
    //Precondition: Can only be set if _onlyValue is 0
    private mutating func setSolvedValue(to value: UInt16) {
        _storage = _storage | (value << 12)
    }
    
    init(allTrue: ()) {
        self._storage = 0b0000001111111110
    }
    
    init(_ value: Int) {
        assert((1...9).contains(value))
        self._storage = 1 << value ^ 0
        setSolvedValue(to: UInt16(truncatingIfNeeded: value))
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
            assert(count > 0)
            if _countNotSolved == 1 {
                for index in 1...9 where contains(index) {
                    setSolvedValue(to: UInt16(truncatingIfNeeded: index))
                }
            }
            return true
        }
        return false
    }
    
    // Prerequisite: the _solvedValue bits must be zero
    private var _countNotSolved: Int {
        assert(_solvedValue == 0)
        // Borrowed from http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSet64
        return (Int(truncatingIfNeeded: _storage) * 0x200040008001 & 0x111111111111111) % 0xf
    }
    
    var count: Int {
        guard !isSolved else { return 1 }
        return _countNotSolved
    }
    
}

extension OneToNineSet: Sequence{
    
    func makeIterator() -> OneToNineSetIterator {
        return OneToNineSetIterator(self)
    }
}

struct OneToNineSetIterator: IteratorProtocol {
    
    var base: OneToNineSet
    private var index = 1
    
    init(_ base: OneToNineSet) { self.base = base }
    
    mutating func next() -> Int? {
        
        guard index < 10 else { return nil }
        
        if base.isSolved {
            index = 10
            return base.solvedValue
        }
        
        repeat {
            defer { index = index &+ 1 }
            if base.contains(index) { return index }
        } while index < 10
        return nil
        
    }
    
}

