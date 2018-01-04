struct SudokuBoard: Equatable {
    
    private var board: [SudokuCell]
    
    init(_ board: [SudokuCell]) {
        precondition(board.count == 81)
        self.board = board
    }
    
    init(_ board: SudokuCell...) {
        self.init(board)
    }
    
    init() {
        self.board = Array(repeating: nil, count: 81)
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
    
    func isValid() -> Bool {
        var validator = SudokuValidator()
        for i in self.indices where self[i] != nil {
            let coordinate = SudokuCoordinate(i)
            guard validator.validate(self[i].cell, at: coordinate) else { return false }
            validator.set(self[i].cell, to: true, at: coordinate)
        }
        return true
    }
    
    func isFullyFilled() -> Bool {
        for cell in self.board where cell == nil { return false }
        return true
    }
    
    func indexFor(row: Int, column: Int) -> Int {
        return row * 9 + column
    }
    
}

extension SudokuBoard: RandomAccessCollection, MutableCollection {
    
    typealias Element = SudokuCell
    
    subscript(index: Int) -> SudokuCell {
        get { return self.board[index] }
        set { self.board[index] = newValue }
    }
    
    var count: Int {
        return self.board.count
    }
    
    var startIndex: Int {
        return self.board.startIndex
    }
    
    var endIndex: Int {
        return self.board.endIndex
    }
    
    func index(after index: Int) -> Int {
        return self.board.index(after: index)
    }
    
    func index(before index: Int) -> Int {
        return self.board.index(before: index)
    }
    
}

extension SudokuBoard: CustomStringConvertible {
    
    var description: String {
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
    
    var debugDescription: String {
        return self.board.reduce(into: "") { result, cell in
            switch cell {
            case nil: result.append("_")
            default: result.append(cell.description)
            }
        }
    }
    
}
