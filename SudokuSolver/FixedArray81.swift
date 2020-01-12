struct FixedArray81<T> {

    // 81 elements
    typealias Storage = (
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T,
        T, T, T, T, T, T, T, T, T)
    
    var storage: Storage
    
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
    
    init(_ storage: Storage) {
        self.storage = storage
    }
    
    init<C: Collection>(_ collection: C) where C.Element == T {
        precondition(collection.count == 81, "Must initialize FixedArray81 with a collection containing exactly 81 elements")
        var i = collection.makeIterator()
        self.storage = (i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!, i.next()!)
    }
    
}

extension FixedArray81 : RandomAccessCollection, MutableCollection {
    
    var startIndex : Int { 0 }
    var endIndex : Int { 81 }
    
    subscript(i: Int) -> T {
        @inline(__always)
        get {
            assert((startIndex..<endIndex).contains(i))
            return withUnsafeBytes(of: storage) { rawPointer in
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

extension FixedArray81 {
    
    func map<Result>(_ transform: (T) -> Result) -> FixedArray81<Result> {
        let t = transform
        return FixedArray81<Result>((t(storage.0) as Result, t(storage.1), t(storage.2), t(storage.3), t(storage.4), t(storage.5), t(storage.6), t(storage.7), t(storage.8), t(storage.9), t(storage.10), t(storage.11), t(storage.12), t(storage.13), t(storage.14), t(storage.15), t(storage.16), t(storage.17), t(storage.18), t(storage.19), t(storage.20), t(storage.21), t(storage.22), t(storage.23), t(storage.24), t(storage.25), t(storage.26), t(storage.27), t(storage.28), t(storage.29), t(storage.30), t(storage.31), t(storage.32), t(storage.33), t(storage.34), t(storage.35), t(storage.36), t(storage.37), t(storage.38), t(storage.39), t(storage.40), t(storage.41), t(storage.42), t(storage.43), t(storage.44), t(storage.45), t(storage.46), t(storage.47), t(storage.48), t(storage.49), t(storage.50), t(storage.51), t(storage.52), t(storage.53), t(storage.54), t(storage.55), t(storage.56), t(storage.57), t(storage.58), t(storage.59), t(storage.60), t(storage.61), t(storage.62), t(storage.63), t(storage.64), t(storage.65), t(storage.66), t(storage.67), t(storage.68), t(storage.69), t(storage.70), t(storage.71), t(storage.72), t(storage.73), t(storage.74), t(storage.75), t(storage.76), t(storage.77), t(storage.78), t(storage.79), t(storage.80)) as FixedArray81<Result>.Storage)
    }
    
}

