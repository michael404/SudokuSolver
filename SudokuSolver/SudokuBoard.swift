public struct SudokuBoard: Equatable {
    
    internal var board: [SudokuCell]
    
    init<C: Collection>(_ board: C) where C.Element == SudokuCell {
        precondition(board.count == 81, "Must pass in 81 SudokuCell elements")
        self.board = Array(board)
    }
    
    init(_ board: SudokuCell...) {
        self.init(board)
    }
    
    init() {
        self.board = Array(repeating: nil, count: 81)
    }
    
    init<S: StringProtocol>(_ board: S) {
        self.board = board.map { character in
            switch character {
            case ".": return nil
            case "1"..."9": return SudokuCell(Int(String(character))!)
            default: preconditionFailure("Unexpected character in string sequence")
            }
        }
        precondition(self.board.count == 81, "Must pass in 81 SudokuCell elements")
    }
    
    subscript(row: Int, column: Int) -> SudokuCell {
        get {
            assert(row >= 0 && row <= 8, "Row must be a value between 0 and 8")
            assert(column >= 0 && column <= 8, "Column must be a value between 0 and 8")
            return self.board[indexFor(row: row, column: column)]
        }
        set(newValue) {
            assert(row >= 0 && row <= 8, "Row must be a value between 0 and 8")
            assert(column >= 0 && column <= 8, "Column must be a value between 0 and 8")
            self.board[indexFor(row: row, column: column)] = newValue
        }
    }
    
    /// Indicates if this Sudoku is valid
    /// If it is not solvable, or violates any of the row/box/column
    /// requirements, or has multiple solutions, it is considered non-valid
    var isValid: Bool {
        return numberOfSolutions() == .one
    }
    
    var isFullyFilled: Bool {
        for cell in self.board where cell == nil { return false }
        return true
    }
    
    var clues: Int {
        return lazy.filter({ $0 != nil }).count
    }
    
    func indexFor(row: Int, column: Int) -> Int {
        return row * 9 + column
    }
    
}

extension SudokuBoard: RandomAccessCollection, MutableCollection {
    
    public typealias Element = SudokuCell
    
    public subscript(index: Int) -> SudokuCell {
        get { return self.board[index] }
        set { self.board[index] = newValue }
    }
    
    public var count: Int {
        return self.board.count
    }
    
    public var startIndex: Int {
        return self.board.startIndex
    }
    
    public var endIndex: Int {
        return self.board.endIndex
    }
    
    public func index(after index: Int) -> Int {
        return self.board.index(after: index)
    }
    
    public func index(before index: Int) -> Int {
        return self.board.index(before: index)
    }
    
}

extension SudokuBoard: CustomStringConvertible {
    
    public var description: String {
        var i = self.board.makeIterator()
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
    
    public var debugDescription: String {
        return self.board.reduce(into: "") { result, cell in
            switch cell {
            case nil: result.append(".")
            default: result.append(cell.description)
            }
        }
    }
    
}
