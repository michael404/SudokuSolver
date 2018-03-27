extension SudokuBoard {
    
    func findFirstSolutionAlt() throws -> SudokuBoard {

        // Returns true once the function has found a solution
        func _solve(_ board: CellOptionBoard, _ indicies: [Int], _ lastChangedIndex: Int = -1) throws -> CellOptionBoard {

            var board = board
            
            //TODO: figure out why this does not improve performance
            if lastChangedIndex == -1 {
                var set = ZeroTo80Set(allFalse: ())
                set[lastChangedIndex] = true
                try board.eliminatePossibilities(for: set)
            } else {
                try board.eliminatePossibilities(for: ZeroTo80Set(allTrue: ()))
            }
            
            guard !indicies.isEmpty else { return board }
            let index = indicies.min { board[$0].numberOfPossibleValues < board[$1].numberOfPossibleValues }!
            
            // Test out possible cell values, and recurse
            for cellValue in board[index].possibleValues {
                board[index] = _Cell(cellValue)
                do {
                    return try _solve(board, indicies.filter(board.hasSingleValueAtIndex), index)
                } catch {
                    continue
                }
            }
            throw SudokuSolverError.unsolvable
        }
        
        let board = CellOptionBoard(self)
        let solvableCellIndicies = board.indices.filter(board.hasSingleValueAtIndex)
        let result = try _solve(board, solvableCellIndicies)
        return SudokuBoard(result)
    }
    
}

struct CellOptionBoard {
    
    var board: FixedArray81<_Cell>
    
    init(_ board: SudokuBoard) {
        self.board = FixedArray81(repeating: _Cell())
        for (index, cell) in zip(board.indices, board) where cell != nil {
            self.board[index] = _Cell(cell.value)
        }
    }
    
    // Throws if we are in an impossible situation
    mutating func eliminatePossibilities(for indicies: ZeroTo80Set) throws {
        
        var updatedIndicies = ZeroTo80Set(allFalse: ())
        for index in indices {
            guard let valueToRemove = board[index].onlyValue else { continue }
            for indexToRemoveFrom in CellOptionBoard.indiciesToRemoveFrom[index] {
                if try board[indexToRemoveFrom].remove(value: valueToRemove) {
                    updatedIndicies[indexToRemoveFrom] = true
                }
            }
        }
        guard !updatedIndicies.isEmpty else { return }
        try eliminatePossibilities(for: updatedIndicies)
    }

    func hasSingleValueAtIndex(_ index: Int) -> Bool {
        return self[index].onlyValue == nil
    }
}

extension CellOptionBoard: MutableCollection, RandomAccessCollection {
    
    typealias Element = _Cell
    typealias Index = Int
    typealias SubSequence = CellOptionBoard
    
    subscript(position: Int) -> _Cell {
        get {
            return board[position]
        }
        set(newValue) {
            board[position] = newValue
        }
    }
    
    var startIndex: Int {
        return board.startIndex
    }
    
    var endIndex: Int {
        return board.endIndex
    }
    
}

struct _Cell {
    
    var possibleValues: OneToNineSet
    
    init() {
        possibleValues = OneToNineSet(allTrue: ())
    }
    
    init(_ value: Int) {
        assert((1...9).contains(value))
        self.possibleValues = OneToNineSet(value)
    }
    
    var onlyValue: Int? {
        return possibleValues.onlyValue
    }
    
    var numberOfPossibleValues: Int {
        return possibleValues.count
    }
    
    // Throws if it is not possible
    // Returns true if values were removed
    mutating func remove(value: Int) throws -> Bool {
        if onlyValue == value {
            //Tried to remove the value that was filled
           throw SudokuSolverError.unsolvable
        }
        return possibleValues.remove(value)
    }
    
}

extension _Cell: CustomStringConvertible {
    
    var description: String {
        if let value = onlyValue {
            return "<\(value)>"
        }
        return Array(possibleValues).description
    }

}

fileprivate extension SudokuBoard {
    
    init(_ cellOptionBoard: CellOptionBoard) {
        self.init(cellOptionBoard.map { cell in
            if let value = cell.onlyValue {
                return SudokuCell(value)
            }
            return nil
        })
    }
    
}
