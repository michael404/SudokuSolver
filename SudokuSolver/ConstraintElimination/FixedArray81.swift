struct FixedArray81<T> {

    // 81 elements
    var storage: (
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T)
    
    init(repeating value: T) {
        self.storage = (
            value, value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value, value,
            value, value, value, value, value, value, value, value, value, value,
            value)
    }
    
}

extension FixedArray81 : RandomAccessCollection, MutableCollection {
    
    var startIndex : Int { return 0 }
    
    var endIndex : Int { return 81 }
    
    subscript(i: Int) -> T {
        @inline(__always)
        get {
            var copy = storage
            let result: T = withUnsafeBytes(of: &copy) {
                (rawPtr : UnsafeRawBufferPointer) -> T in
                let stride = MemoryLayout<T>.stride
                assert(rawPtr.count == 81*stride, "layout mismatch?")
                let bufPtr = UnsafeBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: T.self),
                    count: 81)
                return bufPtr[i]
            }
            return result
        }
        @inline(__always)
        set {
            withUnsafeMutableBytes(of: &storage) { rawBuffer in
                assert(rawBuffer.count == 81*MemoryLayout<T>.stride, "layout mismatch?")
                let buffer = UnsafeMutableBufferPointer<Element>(
                    start: rawBuffer.baseAddress._unsafelyUnwrappedUnchecked.assumingMemoryBound(to: Element.self),
                    count: 81)
                buffer[i] = newValue
            }
        }
    }
    
    func index(after i: Int) -> Int { return i+1 }
    
    func index(before i: Int) -> Int { return i-1 }
}

