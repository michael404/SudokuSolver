struct UnsolvedIndicies {
    
    private(set) var storage: FixedArray81<UInt8> = FixedArray81(repeating: UInt8.max)
    private(set) var startOffset: Int = 0
    
    init(basedOn board: SudokuBoard) {
        for i in self.storage.indices {
            self.storage[i] = UInt8(truncatingIfNeeded: i)
        }
        self.removeAndSort(basedOn: board)
    }
    
    mutating func removeAndSort(basedOn board: SudokuBoard) {
        self.storage[startOffset..<81].sort(by: { board[Int(truncatingIfNeeded: $0)].count < board[Int(truncatingIfNeeded: $1)].count })
        self.startOffset = self.storage[startOffset..<81].firstIndex { board[Int(truncatingIfNeeded: $0)].count != 1 } ?? 81
    }
    
}

extension UnsolvedIndicies: RandomAccessCollection {
    
    var startIndex: Int { 0 }
    var endIndex: Int { 81 - startOffset }
    
    subscript(i: Int) -> Int {
        get {
            let adjustedIndex = i + self.startOffset
            assert((0..<81).contains(adjustedIndex))
            return Int(truncatingIfNeeded: self.storage[adjustedIndex]) }
        set {
            let adjustedIndex = i + self.startOffset
            assert((0..<81).contains(adjustedIndex))
            assert((0..<81).contains(newValue))
            self.storage[adjustedIndex] = UInt8(truncatingIfNeeded: newValue)
        }
    }
    
}
