struct SudokuBoard16: Equatable {
    
    private var cells: Array<SudokuCell16>
    
    static let empty: SudokuBoard16 = SudokuBoard16(empty: ())
    
    private init(empty: ()) {
        self.cells = Array(repeating: SudokuCell16.allTrue, count: 256)
    }
    
    init<S: StringProtocol>(_ numbers: S) {
        precondition(numbers.count == 256, "Must pass in 256 SudokuCell elements")
        self.cells = numbers.map { (char: Character) -> SudokuCell16 in
            switch char {
            case ".": return SudokuCell16.allTrue
            case "0"..."9": return SudokuCell16(solved: Int(String(char))!)
            case "A": return SudokuCell16(solved: 10)
            case "B": return SudokuCell16(solved: 11)
            case "C": return SudokuCell16(solved: 12)
            case "D": return SudokuCell16(solved: 13)
            case "E": return SudokuCell16(solved: 14)
            case "F": return SudokuCell16(solved: 15)
            default: preconditionFailure("Unexpected character \(char) in string sequence")
            }
        }
        
    }
    
    /// Indicates if this Sudoku is valid
    /// If it is not solvable, or violates any of the row/box/column
    /// requirements, or has multiple solutions, it is considered non-valid
    var isValid: Bool { numberOfSolutions() == .one }
    
    var isFullyFilled: Bool { self.allSatisfy { $0.isSolved } }
    
    var clues: Int { lazy.filter({ $0.isSolved }).count }
    
}

extension SudokuBoard16: MutableCollection, RandomAccessCollection {
    
    subscript(position: Int) -> SudokuCell16 {
        @inline(__always) get { cells[position] }
        @inline(__always) set { cells[position] = newValue }
    }
    
    var startIndex: Int { cells.startIndex }
    var endIndex: Int { cells.endIndex }
    
}

extension SudokuBoard16: CustomStringConvertible {
    
    var description: String {
        reduce(into: "") { result, cell in
            result.append(cell.debugDescription)
        }
    }
    
}

