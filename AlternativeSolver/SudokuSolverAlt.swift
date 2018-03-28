extension SudokuBoard {
    
    func findFirstSolutionAlt() throws -> SudokuBoard {

        // Returns true once the function has found a solution
        func _solve(_ board: CellOptionBoard, _ indicies: [Int]) throws -> CellOptionBoard {

            var board = board
            try board.eliminatePossibilities()
            
            guard !indicies.isEmpty else { return board }
            let index = indicies.min { board[$0].numberOfPossibleValues < board[$1].numberOfPossibleValues }!
            
            // Test out possible cell values, and recurse
            for cellValue in board[index].possibleValues {
                board[index] = _Cell(cellValue)
                do {
                    return try _solve(board, indicies.filter(board.isSolvedAtIndex))
                } catch {
                    continue
                }
            }
            throw SudokuSolverError.unsolvable
        }
        
        let board = CellOptionBoard(self)
        let solvableCellIndicies = board.indices.filter(board.isSolvedAtIndex)
        let result = try _solve(board, solvableCellIndicies)
        return SudokuBoard(result)
    }
    
}

//TODO: Fix name
struct CellOptionBoard {
    
    var board: FixedArray81<_Cell>
    
    init(_ board: SudokuBoard) {
        self.board = FixedArray81(repeating: _Cell())
        for (index, cell) in zip(board.indices, board) where cell != nil {
            self.board[index] = _Cell(cell.value)
        }
    }
    
    // Throws if we are in an impossible situation
    mutating func eliminatePossibilities() throws {
        var updated = false
        for index in 0...80 {
            guard let valueToRemove = board[index].solvedValue else { continue }
            for indexToRemoveFrom in CellOptionBoard.indiciesToRemoveFrom[index]
                where try board[indexToRemoveFrom].remove(value: valueToRemove) {
                updated = true
            }
        }
        if updated { try eliminatePossibilities() }
    }

    func isSolvedAtIndex(_ index: Int) -> Bool {
        return self[index].solvedValue == nil
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

//TODO: Fix name
struct _Cell {
    
    var possibleValues: OneToNineSet
    
    init() {
        possibleValues = OneToNineSet(allTrue: ())
    }
    
    init(_ value: Int) {
        assert((1...9).contains(value))
        self.possibleValues = OneToNineSet(value)
    }
    
    var solvedValue: Int? {
        return possibleValues.solvedValue
    }
    
    var numberOfPossibleValues: Int {
        return possibleValues.count
    }
    
    // Throws if it is not possible
    // Returns true if values were removed
    mutating func remove(value: Int) throws -> Bool {
        if solvedValue == value {
            //Tried to remove the value that was filled
           throw SudokuSolverError.unsolvable
        }
        return possibleValues.remove(value)
    }
    
}

extension _Cell: CustomStringConvertible {
    
    var description: String {
        if let value = solvedValue {
            return "<\(value)>"
        }
        return Array(possibleValues).description
    }

}

fileprivate extension SudokuBoard {
    
    init(_ cellOptionBoard: CellOptionBoard) {
        self.init(cellOptionBoard.map { cell in
            if let value = cell.solvedValue {
                return SudokuCell(value)
            }
            return nil
        })
    }
    
}
