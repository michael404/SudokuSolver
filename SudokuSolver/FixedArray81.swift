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
    
    var startIndex : Int { 0 }
    var endIndex : Int { 81 }
    
    subscript(i: Int) -> T {
        @inline(__always)
        get {
            assert((startIndex..<endIndex).contains(i))
            // As of Swift 4.2 and SE-0205 we should be able to just pass `storage` as
            // a non-inout argument, but for some reason, that degrades performance
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
    
    func index(after i: Int) -> Int { i + 1 }
    func index(before i: Int) -> Int { i - 1 }
}

extension FixedArray81: Equatable where T: Equatable {
    static func == (lhs: FixedArray81<T>, rhs: FixedArray81<T>) -> Bool {
        lhs.elementsEqual(rhs)
    }
}

