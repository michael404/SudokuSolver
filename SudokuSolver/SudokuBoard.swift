struct SudokuBoard<SudokuType: SudokuTypeProtocol>: Hashable, Sendable {

    typealias Cell = SudokuCell<SudokuType>

    /// Inline storage for all cells, reinterpreted as `Cell` values by the subscript.
    /// Copying a board is a flat memcpy with no heap allocation or copy-on-write
    /// checks. Any trailing padding stays zero (all writes go through the subscript),
    /// so the synthesized equality and hashing match cell-wise equality.
    private var storage: SudokuType.BoardStorage

    static var empty: SudokuBoard { SudokuBoard(empty: ()) }

    private init(empty: ()) {
        assert(MemoryLayout<SudokuType.BoardStorage>.size >= SudokuType.cells * MemoryLayout<Cell>.stride,
               "BoardStorage is too small to hold \(SudokuType.cells) cells")
        self.storage = SudokuType.zeroBoardStorage
        for index in SudokuType.allCells {
            self[index] = .allTrue
        }
    }

    init<S: StringProtocol>(_ numbers: S) throws {
        guard numbers.count == SudokuType.cells else {
            throw SudokuParseError.invalidBoardLength(expected: SudokuType.cells, actual: numbers.count)
        }
        self = .empty
        for (index, character) in numbers.enumerated() {
            self[index] = try Cell(String(character))
        }
    }
    
    /// Indicates whether this Sudoku has exactly one solution.
    var hasUniqueSolution: Bool { numberOfSolutions() == .one }
    
    @available(*, deprecated, renamed: "hasUniqueSolution")
    var isValid: Bool { hasUniqueSolution }
    
    var isFullyFilled: Bool { self.allSatisfy(\.isSolved) }
    
    var clues: Int { lazy.filter(\.isSolved).count }
    
}

extension SudokuBoard: MutableCollection, RandomAccessCollection {

    var startIndex: Int { 0 }

    var endIndex: Int { SudokuType.cells }

    subscript(index: Int) -> Cell {
        get {
            // This nonmutating read makes the compiler copy the whole inline storage
            // defensively, so it is only for cold paths (printing, counting clues,
            // tests). Hot loops must use `cell(at:)` instead.
            assert(SudokuType.allCells.contains(index), "Index \(index) out of bounds")
            return withUnsafeBytes(of: storage) {
                $0.loadUnaligned(fromByteOffset: index * MemoryLayout<Cell>.stride, as: Cell.self)
            }
        }
        @inline(__always) set {
            setCell(at: index, to: newValue)
        }
    }

    /// Reads a cell through an exclusive borrow of the inline storage, which compiles
    /// to a direct load. The nonmutating subscript getter copies the whole storage
    /// defensively, so hot paths must use this accessor instead. Skips bounds checks
    /// in release builds: call sites only use precomputed internal indices; a bad
    /// index table would be undefined behavior here instead of trapping.
    @inline(__always)
    mutating func cell(at index: Int) -> Cell {
        assert(SudokuType.allCells.contains(index), "Index \(index) out of bounds")
        return withUnsafeMutableBytes(of: &storage) {
            $0.loadUnaligned(fromByteOffset: index * MemoryLayout<Cell>.stride, as: Cell.self)
        }
    }

    /// Writes a cell through an exclusive borrow of the inline storage. See `cell(at:)`
    /// for the bounds-checking caveat.
    @inline(__always)
    mutating func setCell(at index: Int, to newValue: Cell) {
        assert(SudokuType.allCells.contains(index), "Index \(index) out of bounds")
        withUnsafeMutableBytes(of: &storage) {
            $0.storeBytes(of: newValue, toByteOffset: index * MemoryLayout<Cell>.stride, as: Cell.self)
        }
    }

}

extension SudokuBoard: CustomStringConvertible {
    
    var description: String {
        reduce(into: "") { result, cell in
            result.append(cell.debugDescription)
        }
    }
    
}

extension SudokuBoard where SudokuType == Sudoku9 {
    
    var niceDescription: String {
        var i = makeIterator()
         var description = "+-----+-----+-----+\n"
         for _ in 1...3 {
             for _ in 1...3 {
                 description += """
                                |\(i.next()!) \(i.next()!) \(i.next()!)|\
                                \(i.next()!) \(i.next()!) \(i.next()!)|\
                                \(i.next()!) \(i.next()!) \(i.next()!)|\n
                                """
             }
             description += "+-----+-----+-----+\n"
         }
         return description
    }
    
    private static var detailedDescriptionEmpty: [Character] {
        """
        ███████████████████████████████████████████████████████
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        █-----+-----+-----█-----+-----+-----█-----+-----+-----█
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        █-----+-----+-----█-----+-----+-----█-----+-----+-----█
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        ███████████████████████████████████████████████████████
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        █-----+-----+-----█-----+-----+-----█-----+-----+-----█
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        █-----+-----+-----█-----+-----+-----█-----+-----+-----█
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        ███████████████████████████████████████████████████████
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        █-----+-----+-----█-----+-----+-----█-----+-----+-----█
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        █-----+-----+-----█-----+-----+-----█-----+-----+-----█
        █     |     |     █     |     |     █     |     |     █
        █     |     |     █     |     |     █     |     |     █
        ███████████████████████████████████████████████████████
        """.map { $0 }
    }

    var detailedDescription: String {

        var result = Self.detailedDescriptionEmpty
        
        for cell in 0..<81 {
            let boxStartIndex = 57 + (6 * cell) + (114 * (cell / 9))
            for cellValue in 1...5 where self[cell].contains(try! SudokuCell9(String(cellValue))) {
                result[boxStartIndex + cellValue - 1] = Character(String(cellValue))
            }
            for cellValue in 6...9 where self[cell].contains(try! SudokuCell9(String(cellValue))) {
                result[boxStartIndex + 57 + cellValue - 6] = Character(String(cellValue))
            }
        }

        return String(result)
        
    }
    
}
