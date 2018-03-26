struct ZeroTo80Set: Sequence {
    
    private var _storage: (UInt64, UInt64)
    
    init(allZero: ()) {
        self._storage = (0, 0)
    }
    
    init(allSet: ()) {
        self._storage = (0b11111111111111111, UInt64.max)
    }

    subscript(index: Int) -> Bool {
        get {
            if index <= 16 {
                return ((_storage.0 >> index) & 1) == 1
            } else {
                return ((_storage.1 >> (index - 17)) & 1) == 1
            }
        }
        set {
            if index <= 16 {
                let oldValue = ((_storage.0 >> index) & 1) == 1
                switch oldValue {
                case newValue: return
                case true: _storage.0 = 1 << index ^ _storage.0
                case false: _storage.0 = 1 << index | _storage.0
                }
            } else {
                let index = index - 17
                let oldValue = ((_storage.1 >> index) & 1) == 1
                switch oldValue {
                case newValue: return
                case true: _storage.1 = 1 << index ^ _storage.1
                case false: _storage.1 = 1 << index | _storage.1
                }
            }
            
        }
    }
    
    func makeIterator() -> ZeroTo80Iterator {
        return ZeroTo80Iterator(self)
    }
    
    var isEmpty: Bool {
        return _storage == (0, 0)
    }
    
}

struct ZeroTo80Iterator: IteratorProtocol {
    
    var base: ZeroTo80Set
    private var index = 0
    
    init(_ base: ZeroTo80Set) { self.base = base }
    
    mutating func next() -> Int? {
        
        guard index < 81 else { return nil }
        
        repeat {
            defer { index = index &+ 1 }
            if base[index] { return index }
        } while index < 81
        
        return nil
        
    }
    
}


