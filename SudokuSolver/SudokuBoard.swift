struct SudokuBoard: Equatable {
    
    private var cells: FixedArray81<SudokuCell>
    
    static let empty: SudokuBoard = SudokuBoard(empty: ())
    
    private init(empty: ()) {
        self.cells = FixedArray81(repeating: SudokuCell.allTrue)
    }
    
    init<S: StringProtocol>(_ numbers: S) {
        precondition(numbers.count == 81, "Must pass in 81 SudokuCell elements")
        self.cells = FixedArray81(numbers.lazy.map({
            switch $0 {
            case ".": return SudokuCell.allTrue
            case "1"..."9": return SudokuCell(solved: Int(String($0))!)
            default: preconditionFailure("Unexpected character \($0) in string sequence")
            }
        }))
        
    }
    
    /// Indicates if this Sudoku is valid
    /// If it is not solvable, or violates any of the row/box/column
    /// requirements, or has multiple solutions, it is considered non-valid
    var isValid: Bool { numberOfSolutions() == .one }
    
    var isFullyFilled: Bool { self.allSatisfy { $0.isSolved } }
    
    var clues: Int { lazy.filter({ $0.isSolved }).count }
    
    var counts: FixedArray81<UInt8> {
        self.cells.map { UInt8(truncatingIfNeeded: $0.count) }
    }
    
}

extension SudokuBoard: MutableCollection, RandomAccessCollection {
    
    subscript(position: Int) -> SudokuCell {
        @inline(__always) get { cells[position] }
        @inline(__always) set { cells[position] = newValue }
    }
    
    var startIndex: Int { cells.startIndex }
    var endIndex: Int { cells.endIndex }
    
}

extension SudokuBoard: CustomStringConvertible, CustomDebugStringConvertible {

    var description: String {
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
    
    var debugDescription: String {
        reduce(into: "") { result, cell in
            result.append(cell.debugDescription)
        }
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
                if self[cell].contains(SudokuCell(solved: cellValue)) {
                    result[boxStartIndex + cellValue - 1] = Character(String(cellValue))
                }
            }
            for cellValue in 6...9 {
                if self[cell].contains(SudokuCell(solved: cellValue)) {
                    result[boxStartIndex + 57 + cellValue - 6] = Character(String(cellValue))
                }
            }
        }

        return String(result)
        
    }
}

