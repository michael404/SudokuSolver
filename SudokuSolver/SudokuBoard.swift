struct SudokuBoard {
    
    typealias Board = [SudokuCell]
    private var board: Board
    
    init(_ board: Board) {
        precondition(board.count == 81)
        self.board = board
    }
    
    init(_ board: SudokuCell...) {
        self.init(board)
    }
    
    init() {
        self.board = Array(repeating: .empty, count: 81)
    }
    
    subscript(row: Int, column: Int) -> SudokuCell {
        get {
            precondition(row >= 0 && row <= 8, "Row must be a value between 0 and 8")
            precondition(column >= 0 && column <= 8, "Column must be a value between 0 and 8")
            return self.board[indexFor(row: row, column: column)]
        }
        set(newValue) {
            precondition(row >= 0 && row <= 8, "Row must be a value between 0 and 8")
            precondition(column >= 0 && column <= 8, "Column must be a value between 0 and 8")
            self.board[indexFor(row: row, column: column)] = newValue
        }
    }
    
    func isValid() -> Bool {
        var validator = SodukoValidator()
        for i in self.indices {
            let coordinate = SodukoCoordinate(i)
            guard validator.validate(self[i], for: coordinate) else { return false }
            if self[i] != .empty { validator.set(self[i], for: coordinate) }
        }
        return true
    }
    
    func isFullyFilled() -> Bool {
        for cell in self.board where cell == .empty {
            return false
        }
        return true
    }
    
    func indexFor(row: Int, column: Int) -> Int {
        return row * 9 + column
    }
    
}

extension SudokuBoard: RandomAccessCollection, MutableCollection {
    
    typealias Element = SudokuCell
    
    subscript(index: Int) -> SudokuCell {
        get {
            return self.board[index]
        }
        set(newValue) {
            self.board[index] = newValue
        }
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
    
    func index(_ index: Index, offsetBy n: Int) -> Index {
        return self.board.index(index, offsetBy: n)
    }
    
    func distance(from start: Index, to end: Index) -> Int {
        return self.board.distance(from: start, to: end)
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


