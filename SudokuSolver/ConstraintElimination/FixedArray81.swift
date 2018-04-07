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
            assert((startIndex..<endIndex).contains(i))
            //TODO: If SE-0205 passes we can eliminate the copy here and just pass `storage` as a non-inout argument
            var copy = storage
            return withUnsafeBytes(of: &copy) { rawPointer in
                let pointer = rawPointer.baseAddress!.assumingMemoryBound(to: T.self)
                let bufferPointer = UnsafeBufferPointer(start: pointer, count: 81)
                return bufferPointer[i]
            }
        }
        @inline(__always)
        set {
            assert((startIndex..<endIndex).contains(i))
            withUnsafeMutableBytes(of: &storage) { rawPointer in
                let pointer = rawPointer.baseAddress!.assumingMemoryBound(to: T.self)
                let bufferPointer = UnsafeMutableBufferPointer<Element>(start: pointer, count: 81)
                bufferPointer[i] = newValue
            }
        }
    }
    
    func index(after i: Int) -> Int { return i + 1 }
    
    func index(before i: Int) -> Int { return i - 1 }
}

