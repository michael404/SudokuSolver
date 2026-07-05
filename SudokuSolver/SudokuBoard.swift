struct SudokuBoard<SudokuType: SudokuTypeProtocol>: Hashable, Sendable {
    
    typealias Cell = SudokuCell<SudokuType>
    
    private var cells: [Cell]
    
    static var empty: SudokuBoard { SudokuBoard(empty: ()) }
    
    private init(empty: ()) {
        self.cells = Array(repeating: Cell.allTrue, count: SudokuType.cells)
    }
    
    init<S: StringProtocol>(_ numbers: S) throws {
        guard numbers.count == SudokuType.cells else {
            throw SudokuParseError.invalidBoardLength(expected: SudokuType.cells, actual: numbers.count)
        }
        self.cells = try numbers.map { try Cell(String($0)) }
    }
    
    /// Indicates whether this Sudoku has exactly one solution.
    var hasUniqueSolution: Bool { numberOfSolutions() == .one }
    
    @available(*, deprecated, renamed: "hasUniqueSolution")
    var isValid: Bool { hasUniqueSolution }
    
    var isFullyFilled: Bool { self.allSatisfy(\.isSolved) }
    
    var clues: Int { lazy.filter(\.isSolved).count }
    
}

extension SudokuBoard: MutableCollection, RandomAccessCollection {
    
    var startIndex: Int { cells.startIndex }
    
    var endIndex: Int { cells.endIndex }
    
    subscript(index: Int) -> Cell {
        @inline(__always) get {
            // Release builds intentionally skip Array bounds checks on this hot path.
            // Call sites only use precomputed internal indices; a bad index table would
            // be undefined behavior here instead of trapping.
            assert(SudokuType.allCells.contains(index), "Index \(index) out of bounds")
            return self.cells.withUnsafeBufferPointer { $0[index] }
        }
        @inline(__always) set {
            // TODO: Avoid bounds checking in release mode here as well
            self.cells[index] = newValue
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
