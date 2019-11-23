extension UInt16 {
    
    static let allPossibilities: UInt16 = 0b111111111
    
    init(solved value: Int) {
        self.init(0b1 << (value - 1))
    }
    
    init?(from character: Character) {
        switch character {
        case ".": self = .allPossibilities
        case "1": self.init(solved: 1)
        case "2": self.init(solved: 2)
        case "3": self.init(solved: 3)
        case "4": self.init(solved: 4)
        case "5": self.init(solved: 5)
        case "6": self.init(solved: 6)
        case "7": self.init(solved: 7)
        case "8": self.init(solved: 8)
        case "9": self.init(solved: 9)
        default: return nil
        }
    }
    
    var isSolved: Bool {
        return self.nonzeroBitCount == 1
    }
    
    var solvedValueAsNumber: UInt16? {
        let trailingZeroBitCount = UInt16(truncatingIfNeeded: self.trailingZeroBitCount)
        guard self.nonzeroBitCount == 1 && trailingZeroBitCount <= 8 else { return nil }
        return trailingZeroBitCount + 1
    }
    
    var sudokuDescription: String {
        if self == Self.allPossibilities { return "(all)" }
        guard let solvedValue = self.solvedValueAsNumber else {
            return "(\(self.lazy.map({ $0.solvedValueAsNumber! }).map(String.init).joined(separator: " ")))"
        }
        return "[\(solvedValue)]"
        
    }
}

extension UInt16: Sequence {
    
    public func makeIterator() -> Iterator { Iterator(self) }
    
    public struct Iterator: IteratorProtocol {
        
        private var base: UInt16
        private var mask: UInt16 = 0b1
        
        init(_ base: UInt16) { self.base = base }
        
        public mutating func next() -> UInt16? {
            while mask != 0b1000000000 {
                defer { mask <<= 1 }
                if (base & mask) != 0 { return mask }
            }
            return nil
        }
        
    }
    
}
