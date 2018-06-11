struct SudokuBoard: Equatable {
    
    private var cells: FixedArray81<SudokuCell>
    
    static let empty: SudokuBoard = SudokuBoard(empty: ())
    
    private init(empty: ()) {
        self.cells = FixedArray81(repeating: SudokuCell.allTrue)
    }
    
    init<S: StringProtocol>(_ numbers: S) {
        precondition(numbers.count == 81, "Must pass in 81 SudokuCell elements")
        self = SudokuBoard.empty
        for (i, j) in zip(self.indices, numbers.indices) {
            switch numbers[j] {
                
            case ".":
                self[i] = .allTrue
                
            case "1"..."9":
                self[i] = SudokuCell(solved: Int(String(numbers[j]))!)
                
            default:
                preconditionFailure("Unexpected character in string sequence")
            }
        }
        
    }
    
    /// Indicates if this Sudoku is valid
    /// If it is not solvable, or violates any of the row/box/column
    /// requirements, or has multiple solutions, it is considered non-valid
    var isValid: Bool {
        return numberOfSolutions() == .one
    }
    
    var isFullyFilled: Bool {
        for cell in self where !cell.isSolved { return false }
        return true
    }
    
    var clues: Int {
        return lazy.filter({ $0.isSolved }).count
    }
    
}

extension SudokuBoard: MutableCollection, RandomAccessCollection {
    
    subscript(position: Int) -> SudokuCell {
        @inline(__always) get { return cells[position] }
        @inline(__always) set { cells[position] = newValue }
    }
    
    var startIndex: Int { return cells.startIndex }
    
    var endIndex: Int { return cells.endIndex }
    
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
        return reduce(into: "") { result, cell in
            result.append(cell.debugDescription)
        }
    }

}
