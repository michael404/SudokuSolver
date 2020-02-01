protocol SudokuCellProtocol: Hashable, CustomStringConvertible, CustomDebugStringConvertible, BidirectionalSequence where Element == Self {
    
    associatedtype Storage: BinaryInteger
    associatedtype IteratorStorage: HighestSetBitProtocol
    init(solved: Int)
    init(storage: Storage)
    init(character: Character)
    var storage: Storage { get }
    var isSolved: Bool { get }
    var count: Int { get }
    func contains(_ value: Self) -> Bool
    mutating func remove(_ value: Self) throws -> Bool
    static var allTrue: Self { get }
    
}

//TODO: Consider if we can implement some of the methods in an extention here

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
