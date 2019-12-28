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
    
    init(_ v0: T, _ v1: T, _ v2: T, _ v3: T, _ v4: T, _ v5: T, _ v6: T, _ v7: T, _ v8: T, _ v9: T, _ v10: T, _ v11: T, _ v12: T, _ v13: T, _ v14: T, _ v15: T, _ v16: T, _ v17: T, _ v18: T, _ v19: T, _ v20: T, _ v21: T, _ v22: T, _ v23: T, _ v24: T, _ v25: T, _ v26: T, _ v27: T, _ v28: T, _ v29: T, _ v30: T, _ v31: T, _ v32: T, _ v33: T, _ v34: T, _ v35: T, _ v36: T, _ v37: T, _ v38: T, _ v39: T, _ v40: T, _ v41: T, _ v42: T, _ v43: T, _ v44: T, _ v45: T, _ v46: T, _ v47: T, _ v48: T, _ v49: T, _ v50: T, _ v51: T, _ v52: T, _ v53: T, _ v54: T, _ v55: T, _ v56: T, _ v57: T, _ v58: T, _ v59: T, _ v60: T, _ v61: T, _ v62: T, _ v63: T, _ v64: T, _ v65: T, _ v66: T, _ v67: T, _ v68: T, _ v69: T, _ v70: T, _ v71: T, _ v72: T, _ v73: T, _ v74: T, _ v75: T, _ v76: T, _ v77: T, _ v78: T, _ v79: T, _ v80: T) {
        self.storage = (v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72, v73, v74, v75, v76, v77, v78, v79, v80)
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
        return FixedArray81<Result>(t(storage.0), t(storage.1), t(storage.2), t(storage.3), t(storage.4), t(storage.5), t(storage.6), t(storage.7), t(storage.8), t(storage.9), t(storage.10), t(storage.11), t(storage.12), t(storage.13), t(storage.14), t(storage.15), t(storage.16), t(storage.17), t(storage.18), t(storage.19), t(storage.20), t(storage.21), t(storage.22), t(storage.23), t(storage.24), t(storage.25), t(storage.26), t(storage.27), t(storage.28), t(storage.29), t(storage.30), t(storage.31), t(storage.32), t(storage.33), t(storage.34), t(storage.35), t(storage.36), t(storage.37), t(storage.38), t(storage.39), t(storage.40), t(storage.41), t(storage.42), t(storage.43), t(storage.44), t(storage.45), t(storage.46), t(storage.47), t(storage.48), t(storage.49), t(storage.50), t(storage.51), t(storage.52), t(storage.53), t(storage.54), t(storage.55), t(storage.56), t(storage.57), t(storage.58), t(storage.59), t(storage.60), t(storage.61), t(storage.62), t(storage.63), t(storage.64), t(storage.65), t(storage.66), t(storage.67), t(storage.68), t(storage.69), t(storage.70), t(storage.71), t(storage.72), t(storage.73), t(storage.74), t(storage.75), t(storage.76), t(storage.77), t(storage.78), t(storage.79), t(storage.80))
    }
    
}

