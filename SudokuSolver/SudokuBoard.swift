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
            case "1": return SudokuCell(solved: 1)
            case "2": return SudokuCell(solved: 2)
            case "3": return SudokuCell(solved: 3)
            case "4": return SudokuCell(solved: 4)
            case "5": return SudokuCell(solved: 5)
            case "6": return SudokuCell(solved: 6)
            case "7": return SudokuCell(solved: 7)
            case "8": return SudokuCell(solved: 8)
            case "9": return SudokuCell(solved: 9)
            default: preconditionFailure("Unexpected character in string sequence")
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

extension SudokuBoard: CustomStringConvertible {

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

}

extension SudokuBoard: CustomDebugStringConvertible {

    var debugDescription: String {
        reduce(into: "") { result, cell in
            result.append(cell.debugDescription)
        }
    }

}
