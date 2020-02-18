struct SudokuCell<SudokuType: SudokuTypeProtocol>: Hashable {

    typealias Storage = SudokuType.CellStorage
    
    static var allTrue: Self { Self(storage: SudokuType.allTrueCellStorage) }
    
    var storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    init(_ string: String) {
        if string == "." {
            self = .allTrue
        } else if let value = SudokuType.solvedRepresentationReversed[string] {
            self.storage = 1 << value
        } else {
            fatalError("Tried to initialize cell for \(SudokuType.self) with invalid string \(string)")
        }
    }
    
    /// The number of possible values for this cell
    var count: Int { storage.nonzeroBitCount }
    
    var isSolved: Bool { storage.nonzeroBitCount == 1 }
    
    var solvedValue: Self? { isSolved ? self : nil }
    
    func contains(_ value: Self) -> Bool { (storage & value.storage) != 0 }
    
    /// Returns true if a value was removed
    /// Throws if the last value was removed
    /// This method supports removing multiple values at a time
    mutating func remove(_ value: Self) throws -> Bool {
        let original = self
        self.storage &= ~value.storage
        if self.storage == 0 { throw SudokuSolverError.unsolvable }
        return self != original
    }
}

extension SudokuCell: CustomStringConvertible, CustomDebugStringConvertible {
    
    var description: String { isSolved ? SudokuType.solvedRepresentation[storage.trailingZeroBitCount] : " " }

    var debugDescription: String { isSolved ? SudokuType.solvedRepresentation[storage.trailingZeroBitCount] : "." }
    
}

extension SudokuCell: Sequence {
    
    typealias Element = Self
    
    func makeIterator() -> Iterator { Iterator(self) }
    
    struct Iterator: IteratorProtocol {
        
        private var remaining: SudokuType.CellIteratorStorage
        
        init(_ cell: SudokuCell<SudokuType>) {
            self.remaining = SudokuType.CellIteratorStorage(truncatingIfNeeded: cell.storage)
        }
        
        mutating func next() -> SudokuCell<SudokuType>? {
            guard remaining != 0 else { return nil }
            let lowestBitSet = remaining & -remaining
            self.remaining ^= lowestBitSet
            return SudokuCell<SudokuType>(storage: SudokuType.CellStorage(truncatingIfNeeded: lowestBitSet))
        }
        
    }
        
}
