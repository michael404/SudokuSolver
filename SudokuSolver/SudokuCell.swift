struct SudokuCell<SudokuType: SudokuTypeProtocol>: Hashable {

    typealias Storage = SudokuType.CellStorage
    
    static var allTrue: Self { Self(storage: SudokuType.allTrueCellStorage) }
    
    var storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    init(_ character: Character) {
        if character == "." {
            self = .allTrue
        } else {
            guard let value = SudokuType.solvedRepresentationReversed[String(character)] else {
                fatalError("Tried to initialize cell for \(SudokuType.self) with character \(character)")
            }
            self.storage = 1 << value
        }
    }
    
    init(_ string: String) {
        guard string.count == 1 else {
            fatalError("Cannot initialize SudokuCell with string of length \(string.count). Expected length 1")
        }
        self.init(string.first!)
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
        
        typealias IteratorStorage = SudokuType.CellIteratorStorage

        private var remaining: IteratorStorage
        
        init(_ cell: SudokuCell<SudokuType>) {
            self.remaining = IteratorStorage(truncatingIfNeeded: cell.storage)
        }
        
        mutating func next() -> SudokuCell<SudokuType>? {
            guard remaining != 0 else { return nil }
            let lowestBitSet = remaining & -remaining
            self.remaining ^= lowestBitSet
            return SudokuCell<SudokuType>(storage: SudokuType.CellStorage(truncatingIfNeeded: lowestBitSet))
        }
        
    }
        
}

extension SudokuCell {
    
    func makeReverseSequence() -> ReverseSequence { ReverseSequence(cell: self) }

    struct ReverseSequence: Sequence {
        
        let cell: SudokuCell<SudokuType>
        
        func makeIterator() -> Iterator { Iterator(cell) }
        
        struct Iterator: IteratorProtocol {
            
            typealias IteratorStorage = SudokuType.CellIteratorStorage
            
            private var remaining: IteratorStorage
            
            init(_ cell: SudokuCell<SudokuType>) {
                self.remaining = IteratorStorage(truncatingIfNeeded: cell.storage)
            }
            
            mutating func next() -> SudokuCell<SudokuType>? {
                guard remaining != 0 else { return nil }
                let highestSetBit = remaining.highestSetBit
                self.remaining ^= highestSetBit
                return SudokuCell<SudokuType>(storage: SudokuType.CellStorage(truncatingIfNeeded: highestSetBit))
            }
            
        }
        
    }
    
}



