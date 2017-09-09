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
        return validateAllRows() && validateAllBlocks() && validateAllColumns()
    }
    
    func isValid(for index: Int) -> Bool {
        return validateRow(for: index) &&
               validateBlock(for: index) &&
               validateColumn(for: index)
    }
    
    func isFullyFilled() -> Bool {
        for cell in self.board where cell == .empty {
            return false
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
    
    func validateAllRows() -> Bool {
        for start in stride(from: 0, to: 80, by: 9) {
            let row = self.board[start...(start + 8)]
            guard validate(row) else { return false }
        }
        return true
    }
    
    func validateRow(for index: Int) -> Bool {
        let start = row(for: index) * 9
        return validate(self.board[start...(start + 8)])
    }
    
    func validateAllBlocks() -> Bool {
        // Iterate over block offsets
        for b in [0, 3, 6, 27, 30, 33, 54, 57, 60] {
            let valid = validate([board[b+0 ], board[b+1 ], board[b+2 ],
                                  board[b+9 ], board[b+10], board[b+11],
                                  board[b+18], board[b+19], board[b+20]])
            guard valid else { return false }
        }
        return true
    }
    
    func validateBlock(for index: Int) -> Bool {
        let baseRow = (row(for: index) / 3) * 3
        let baseColumn = (column(for: index) / 3) * 3
        let b = indexFor(row: baseRow, column: baseColumn)
        return validate([board[b+0 ], board[b+1 ], board[b+2 ],
                         board[b+9 ], board[b+10], board[b+11],
                         board[b+18], board[b+19], board[b+20]])
    }
    
    func validateAllColumns() -> Bool {
        for c in 0...8 {
            let valid = validate([board[c+0 ], board[c+9 ], board[c+18],
                                  board[c+27], board[c+36], board[c+45],
                                  board[c+54], board[c+63], board[c+72]])
            guard valid else { return false }
        }
        return true
    }
    
    func validateColumn(for index: Int) -> Bool {
        let c = column(for: index)
        return validate([board[c+0 ], board[c+9 ], board[c+18],
                         board[c+27], board[c+36], board[c+45],
                         board[c+54], board[c+63], board[c+72]])
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

