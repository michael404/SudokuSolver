struct SudokuCell4: SudokuCellProtocol {
    
    typealias Storage = UInt8
    typealias IteratorStorage = Int8
    
    var storage: UInt8
    
    static var allTrue: SudokuCell4 = Self(storage: 0b1111)

    
    init(solved value: Int) {
        assert((1...4).contains(value))
        self.storage = 1 << (value - 1) as UInt8
    }
    
    init(storage: UInt8) {
        self.storage = storage
    }
    
    init(character: Character) {
        switch character {
        case ".": self = Self.allTrue
        case "1"..."4": self = Self(solved: Int(String(character))!)
        default: preconditionFailure("Unexpected character \(character) in string sequence")
        }
    }
    
    #warning("Move these into the protocol?")
    var description: String { isSolved ? String(Int(self)) : " " }
    var debugDescription: String { isSolved ? String(Int(self)) : "." }
    
}

extension Int {
    
    init(_ value: SudokuCell4) {
        precondition(value.isSolved, "Int must be initialized with a solved value")
        self = value.storage.trailingZeroBitCount + 1
    }
}
