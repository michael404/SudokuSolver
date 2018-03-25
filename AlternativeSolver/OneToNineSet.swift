struct OneToNineSet: Sequence {
    
    private var _storage: UInt16
    
    private var _count: UInt8
    
    //TODO: Evaluate if this cache is necessary after other performance optimizations
    /// The only value if there is only one value. 0 otherwise
    fileprivate var _onlyValue: UInt8
    
    init(allTrue: ()) {
        self._storage = 0b1111111110
        self._count = 9
        self._onlyValue = 0
    }
    
    init(_ value: Int) {
        assert((1...9).contains(value))
        self._storage = 1 << value ^ 0
        self._count = 1
        self._onlyValue = UInt8(truncatingIfNeeded: value)
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
            _count = _count &- 1
            if _count == 1 {
                for index in 1...9 where contains(index) {
                    _onlyValue = UInt8(truncatingIfNeeded: index)
                }
            }
            return true
        }
        return false
    }
    
    var count: Int {
        return Int(truncatingIfNeeded: _count)
    }
    
    var hasSingeValue: Bool {
        return _count == 1
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
            return Int(truncatingIfNeeded: base._onlyValue)
        }
        
        repeat {
            defer { index = index &+ 1 }
            if base.contains(index) { return index }
        } while index < 10
        
        return nil
    }
    
}

