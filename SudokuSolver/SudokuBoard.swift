struct SudokuBoard {
    
    typealias Board = [SudokuCell]
    private var board: Board
    
    init(_ board: Board) {
        precondition(board.count == 81)
        self.board = board
    }
    
    init() {
        self.board = Array(repeating: .empty, count: 81)
    }
    
    subscript(row: Int, column: Int) -> SudokuCell {
        get {
            precondition(row >= 0)
            precondition(row <= 8)
            precondition(column >= 0)
            precondition(column <= 8)
            return self.board[indexFor(row: row, column: column)]
        }
        set(newValue) {
            precondition(row >= 0)
            precondition(row <= 8)
            precondition(column >= 0)
            precondition(column <= 8)
            self.board[indexFor(row: row, column: column)] = newValue
        }
    }
    
    func isValid() -> Bool {
        return validateRows() && validateColumns() && validateBlocks()
    }
    
    func isFullyFilled() -> Bool {
        for cell in self.board {
            if cell == .empty { return false }
        }
        return true
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
                description += "|\(i.next()!) \(i.next()!) \(i.next()!)|\(i.next()!) \(i.next()!) \(i.next()!)|\(i.next()!) \(i.next()!) \(i.next()!)|\n"
            }
            description += "+-----+-----+-----+\n"
        }
        return description
    }
    
}

private extension SudokuBoard {
    
    private func row(for index: Int) -> Int {
        return index / 9
    }
    
    private func column(for index: Int) -> Int {
        return index % 9
    }
    
    private func indexFor(row: Int, column: Int) -> Int {
        return row * 9 + column
    }

}

private extension SudokuBoard {
    
    func validateRows() -> Bool {
        for start in stride(from: 0, to: 80, by: 9) {
            let end = start + 8
            let row = self.board[start...end]
            guard validate(row) else { return false }
        }
        return true
    }
    
    func validateColumns() -> Bool {
        // Iterate over column offsets
        for o in 0...8 {
            let valid = validate([board[o+0 ], board[o+9 ], board[o+18],
                                  board[o+27], board[o+36], board[o+45],
                                  board[o+54], board[o+63], board[o+72]])
            guard valid else { return false }
        }
        return true
    }
    
    func validateBlocks() -> Bool {
        // Iterate over block offsets
        for o in [0, 3, 6, 27, 30, 33, 54, 57, 60] {
            let valid = validate([board[o+0 ], board[o+1 ], board[o+2 ],
                                  board[o+9 ], board[o+10], board[o+11],
                                  board[o+18], board[o+19], board[o+20]])
            guard valid else { return false }
        }
        return true
    }
    
    func validate<S: Sequence>(_ cells: S) -> Bool where S.Element == SudokuCell {
        var validationArray = Array(repeating: false, count: 10)
        for cell in cells {
            switch (cell, validationArray[cell.rawValue]) {
            case (.empty, _):
                continue
            case (_, false):
                validationArray[cell.rawValue] = true
            case (_, true):
                return false
            }
        }
        return true
    }
    
}

