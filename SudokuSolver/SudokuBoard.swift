struct SudokuBoard<SudokuType: SudokuTypeProtocol>: Hashable {
    
    typealias Cell = SudokuCell<SudokuType>
    
    private var cells: [Cell]
    
    static var empty: SudokuBoard { SudokuBoard(empty: ()) }
    
    private init(empty: ()) {
        self.cells = Array(repeating: Cell.allTrue, count: SudokuType.cells)
    }
    
    init<S: StringProtocol>(_ numbers: S) {
        precondition(numbers.count == SudokuType.cells, "Must pass in \(SudokuType.cells) elements")
        self.cells = numbers.map { Cell(String($0)) }
    }
    
    /// Indicates if this Sudoku is valid
    /// If it is not solvable, or violates any of the row/box/column
    /// requirements, or has multiple solutions, it is considered non-valid
    var isValid: Bool { numberOfSolutions() == .one }
    
    var isFullyFilled: Bool { self.allSatisfy(\.isSolved) }
    
    var clues: Int { lazy.filter(\.isSolved).count }
    
}

extension SudokuBoard: MutableCollection, RandomAccessCollection {
    
    var startIndex: Int { cells.startIndex }
    
    var endIndex: Int { cells.endIndex }
    
    subscript(index: Int) -> Cell {
        @inline(__always) get {
            assert(SudokuType.allCells.contains(index), "Index \(index) out of bounds")
            return self.cells.withUnsafeBufferPointer { $0[index] }
        }
        @inline(__always) set {
            //TODO: Avoid bounds checking in release mode here as well
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
            for cellValue in 1...5 {
                if self[cell].contains(SudokuCell9(String(cellValue))) {
                    result[boxStartIndex + cellValue - 1] = Character(String(cellValue))
                }
            }
            for cellValue in 6...9 {
                if self[cell].contains(SudokuCell9(String(cellValue))) {
                    result[boxStartIndex + 57 + cellValue - 6] = Character(String(cellValue))
                }
            }
        }

        return String(result)
        
    }
    
}
