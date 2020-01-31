struct SudokuBoardGeneric<SudokuType: SudokuTypeProtocol>: Equatable {
    
    typealias Cell = SudokuType.Cell
    
    //TODO: Consider if we need a FixedArray here for Sudoku9, and in that case, add an associatedtype to SudokuType
    private var cells: [Cell]
    
    static var empty: SudokuBoardGeneric { SudokuBoardGeneric(empty: ()) }
    
    private init(empty: ()) {
        self.cells = Array(repeating: Cell.allTrue, count: SudokuType.cells)
    }
    
    init<S: StringProtocol>(_ numbers: S) {
        precondition(numbers.count == SudokuType.cells, "Must pass in \(SudokuType.cells) elements")
        self.cells = numbers.map(Cell.init(character:))
    }
    
    /// Indicates if this Sudoku is valid
    /// If it is not solvable, or violates any of the row/box/column
    /// requirements, or has multiple solutions, it is considered non-valid
    var isValid: Bool { numberOfSolutions() == .one }
    
    var isFullyFilled: Bool { self.allSatisfy { $0.isSolved } }
    
    var clues: Int { lazy.filter({ $0.isSolved }).count }
    
}

extension SudokuBoardGeneric: MutableCollection, RandomAccessCollection {
    
    var startIndex: Int { cells.startIndex }
    var endIndex: Int { cells.endIndex }
    subscript(position: Int) -> Cell {
        @inline(__always) get { cells[position] }
        @inline(__always) set { cells[position] = newValue }
    }

}

extension SudokuBoardGeneric: CustomStringConvertible {
    
    var description: String {
        reduce(into: "") { result, cell in
            result.append(cell.debugDescription)
        }
    }
    
}

