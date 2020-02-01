protocol SudokuCellProtocol: Hashable, CustomStringConvertible, CustomDebugStringConvertible, Sequence where Element == Self {
    
    associatedtype Storage: BinaryInteger & FixedWidthInteger
    associatedtype IteratorStorage: SudokuCellIteratorStorageProtocol
    init(solved: Int)
    init(storage: Storage)
    init(character: Character)
    var storage: Storage { get set }
    static var allTrue: Self { get }
    
}

extension SudokuCellProtocol {
    
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

extension SudokuCellProtocol {
    
    func makeIterator() -> SudokuCellIterator<Self> { SudokuCellIterator(self) }
    func makeReverseSequence() -> SudokuCellReverseSequence<Self> { SudokuCellReverseSequence(cell: self) }
    
}

struct SudokuCellIterator<Cell: SudokuCellProtocol>: IteratorProtocol {

    private var remaining: Cell.IteratorStorage
    
    init(_ cell: Cell) {
        self.remaining = Cell.IteratorStorage(truncatingIfNeeded: cell.storage)
    }
    
    mutating func next() -> Cell? {
        guard remaining != 0 else { return nil }
        let lowestBitSet = remaining & -remaining
        self.remaining ^= lowestBitSet
        return Cell(storage: Cell.Storage(truncatingIfNeeded: lowestBitSet))
    }
    
}

struct SudokuCellReverseSequence<Cell: SudokuCellProtocol>: Sequence {
    
    let cell: Cell
    
    func makeIterator() -> Iterator { Iterator(cell) }
    
    struct Iterator: IteratorProtocol {
        
        private var remaining: Cell.IteratorStorage
        
        init(_ cell: Cell) {
            self.remaining = Cell.IteratorStorage(truncatingIfNeeded: cell.storage)
        }
        
        mutating func next() -> Cell? {
            guard remaining != 0 else { return nil }
            let highestSetBit = remaining.highestSetBit
            self.remaining ^= highestSetBit
            return Cell(storage: Cell.Storage(truncatingIfNeeded: highestSetBit))
        }
        
    }
    
}
