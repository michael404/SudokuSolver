struct SudokuCell<SudokuType: SudokuTypeProtocol>: Hashable, Sendable {

    typealias Storage = SudokuType.CellStorage

    static var allTrue: Self { Self(storage: SudokuType.allTrueCellStorage) }
    
    var storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }

    init(_ string: String) throws {
        if string == "." {
            self = .allTrue
        } else if let value = SudokuType.solvedRepresentationReversed[string] {
            self.storage = 1 << value
        } else {
            throw SudokuParseError.invalidCell(string)
        }
    }
    
    /// The number of possible values for this cell
    var count: Int { storage.nonzeroBitCount }
    
    var isSolved: Bool {
        // Exactly-one-bit check without a popcount. Cells always have at least one
        // possibility (removing the last one is rejected), so zero storage cannot occur.
        assert(storage != 0)
        return storage & (storage &- 1) == 0
    }
    
    var solvedValue: Self? { isSolved ? self : nil }
    
    func contains(_ value: Self) -> Bool { (storage & value.storage) != 0 }
    
    /// Returns true if a value was removed
    /// Throws if the last value was removed
    /// This method supports removing multiple values at a time
    mutating func remove(_ value: Self) throws -> Bool {
        guard let result = removeIfPossible(value) else { throw SudokuSolverError.unsolvable }
        return result
    }

    /// Returns nil if the last value would be removed.
    mutating func removeIfPossible(_ value: Self) -> Bool? {
        let original = self.storage
        let newStorage = original & ~value.storage
        guard newStorage != 0 else { return nil }
        self.storage = newStorage
        return newStorage != original
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
            assert(
                SudokuType.CellIteratorStorage(truncatingIfNeeded: SudokuType.allTrueCellStorage) > 0,
                "CellIteratorStorage must hold the full cell mask without setting the sign bit")
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
