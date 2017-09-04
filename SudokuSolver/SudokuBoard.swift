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
        var iterator = self.board.makeIterator()
        var description = "+-----+-----+-----+\n"
        for _ in 1...3 {
            for _ in 1...3 {
                description += "|"
                for _ in 1...3 {
                    description += "\(iterator.next()!) \(iterator.next()!) \(iterator.next()!)|"
                }
                description += "\n"
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
        for columnIndex in 0...8 {
            var column: [SudokuCell] = []
            for rowIndex in 0...8 {
                column.append(self[rowIndex, columnIndex])
            }
            guard validate(column) else { return false }
        }
        return true
    }
    
    func validateBlocks() -> Bool {
        //TODO: Implement this with a fixed array of [0,1,2,9,10,11,...] and a fixed offet at this start using a stride
        for rowBaseIndex in stride(from: 0, to: 8, by: 3) {
            for columnBaseIndex in stride(from: 0, to: 8, by: 3) {
                var block: [SudokuCell] = []
                for rowIndex in rowBaseIndex...(rowBaseIndex + 2) {
                    for columnIndex in columnBaseIndex...(columnBaseIndex + 2) {
                        block.append(self[rowIndex, columnIndex])
                    }
                }
                guard validate(block) else { return false }
            }
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

