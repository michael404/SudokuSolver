struct _FixedArray81<T> {

    var storage: (T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T, T,
        T)
    
}

extension _FixedArray81 : RandomAccessCollection, MutableCollection {
    
    typealias Index = Int
    
    var startIndex : Index {
        return 0
    }
    
    var endIndex : Index {
        return 81
    }
    
    internal subscript(i: Index) -> T {
        @inline(__always)
        get {
            var copy = storage
            let res: T = withUnsafeBytes(of: &copy) {
                (rawPtr : UnsafeRawBufferPointer) -> T in
                let stride = MemoryLayout<T>.stride
                assert(rawPtr.count == 81*stride, "layout mismatch?")
                let bufPtr = UnsafeBufferPointer(
                    start: rawPtr.baseAddress!.assumingMemoryBound(to: T.self),
                    count: 81)
                return bufPtr[i]
            }
            return res
        }
        @inline(__always)
        set {
            self.withUnsafeMutableBufferPointer { buffer in
                buffer[i] = newValue
            }
        }
    }
    
    @inline(__always)
    internal func index(after i: Index) -> Index {
        return i+1
    }
    
    @inline(__always)
    internal func index(before i: Index) -> Index {
        return i-1
    }
}

