struct FixedArray81<T> {

    // 81 elements
    var storage: (
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T)
    
    init(repeating value: T) {
        self.storage = (
            value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value)
    }
    
}

extension FixedArray81 : RandomAccessCollection, MutableCollection {
    
    var startIndex : Int { return 0 }
    
    var endIndex : Int { return 81 }
    
    subscript(i: Int) -> T {
        @inline(__always)
        get {
            //TODO: If SE-0205 passes - see if we can eliminate the copy here
            var copy = storage
            return withUnsafeBytes(of: &copy) { (rawPtr : UnsafeRawBufferPointer) -> T in
                let buffer = UnsafeBufferPointer(start: rawPtr.baseAddress!.assumingMemoryBound(to: T.self), count: 81)
                return buffer[i]
            }
        }
        @inline(__always)
        set {
            withUnsafeMutableBytes(of: &storage) { rawPtr in
                let buffer = UnsafeMutableBufferPointer<Element>(start: rawPtr.baseAddress!.assumingMemoryBound(to: T.self), count: 81)
                buffer[i] = newValue
            }
        }
    }
    
    func index(after i: Int) -> Int { return i + 1 }
    
    func index(before i: Int) -> Int { return i - 1 }
}

