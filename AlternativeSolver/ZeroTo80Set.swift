struct ZeroTo80Set {
    
    private var _storage: (UInt64, UInt64)
    
    init(allFalse: ()) {
        self._storage = (0, 0)
    }
    
    init(allTrue: ()) {
        self._storage = (0b11111111111111111, UInt64.max)
    }
    
    init(_ value: Int) {
        assert((0...80).contains(value))
        self.init(allFalse: ())
        self[value] = true
    }

    subscript(index: Int) -> Bool {
        get {
            assert((0...80).contains(index))
            if index <= 16 {
                return ((_storage.0 >> index) & 1) == 1
            } else {
                return ((_storage.1 >> (index - 17)) & 1) == 1
            }
        }
        set {
            assert((0...80).contains(index))
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
    
    var isEmpty: Bool {
        return _storage == (0, 0)
    }
    
}

extension ZeroTo80Set: Sequence {

    func makeIterator() -> ZeroTo80SetIterator {
        return ZeroTo80SetIterator(self)
    }
    
}

struct ZeroTo80SetIterator: IteratorProtocol {
    
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


