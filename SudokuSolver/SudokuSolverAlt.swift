extension SudokuBoard {
    
    func findFirstSolutionAlt() throws -> SudokuBoard {
        
        var board = CellOptionBoard(self)
        
        try board.eliminatePossibilities()

        // Returns true once the function has found a solution
        func _solve(_ board: CellOptionBoard) throws -> CellOptionBoard {

            var board = board
            //TODO: The first run of this could be triggered for one cell only, since we have only changed one value
            try board.eliminatePossibilities()
            
            //TODO: Generate a cell iterator outside and send it to the function. Consider if it needs to resorted (only first item)
            guard let index = board.index(where: { $0.onlyValue == nil }) else { return board }
            
            // Test out all cellValues, and recurse
            for cellValue in board[index].possibleValues {
                board[index] = _Cell(cellValue)
                do {
                    return try _solve(board)
                } catch {
                    continue
                }
            }
            throw SudokuSolverError.unsolvable
        }
        let result = try _solve(board)
        return SudokuBoard(result)
        

        
    }
    
}

fileprivate struct CellOptionBoard {
    
    var board: [_Cell]
    
    init(_ board: SudokuBoard) {
        self.board = Array(repeating: _Cell(), count: 81)
        for index in board.indices where board[index] != nil {
            self.board[index] = _Cell(board[index].value)
        }
    }
    
    // Throws if we are in an impossible situation
    mutating func eliminatePossibilities() throws {
        
        var valuesWereRemoved: Bool
        repeat {
            valuesWereRemoved = false
            for index in board.indices {
                if let valueToRemove = board[index].onlyValue {
                    
                    for indexToRemoveFrom in CellOptionBoard.indiciesToRemoveFrom[index] {
                        if try board[indexToRemoveFrom].remove(value: valueToRemove) {
                            valuesWereRemoved = true
                        }
                    }
                }
            }
        } while valuesWereRemoved
    }
}

extension CellOptionBoard {
    
    private static var indiciesToRemoveFrom: [Set<Int>] = {
        var result: [Set<Int>] = []
        for index in 0..<81 {
            var indicies = Set<Int>()
            indiciesInSameRow(as: index).forEach { indicies.insert($0) }
            indiciesInSameColumn(as: index).forEach { indicies.insert($0) }
            indiciesInSameBox(as: index).forEach { indicies.insert($0) }
            //Remove self
            indicies.remove(index)
            result.append(indicies)
        }
        return result
    }()
    
    private static func indiciesInSameRow(as index: Int) -> Range<Int> {
        let start = (index / 9) * 9
        let end = start + 9
        return start..<end
    }
    
    private static func indiciesInSameColumn(as index: Int) -> StrideTo<Int> {
        let start = index % 9
        return stride(from: start, to: 81, by: 9)
    }
    
    private static func indiciesInSameBox(as index: Int) -> [Int] {
        //TODO: This can probably be simplified
        let row = index / 9
        let column = index % 9
        var startIndexOfBlock: Int
        switch row {
        case 0...2: startIndexOfBlock = 0
        case 3...5: startIndexOfBlock = 27
        case 6...8: startIndexOfBlock = 54
        default: preconditionFailure()
        }
        switch column {
        case 3...5: startIndexOfBlock += 3
        case 6...8: startIndexOfBlock += 6
        default: break
        }
        return [0,1,2,9,10,11,18,19,20].map { startIndexOfBlock + $0 }
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

fileprivate struct _Cell {
    
    var possibleValues: Set<Int>
    
    init() {
        possibleValues = Set(1...9)
    }
    
    init(_ value: Int) {
        assert((1...9).contains(value))
        self.possibleValues = Set(CollectionOfOne(value))
    }
    
    var onlyValue: Int? {
        if possibleValues.count == 1 {
            return possibleValues.first!
        }
        return nil
    }
    
    // Throws if it is not possible
    // Returns true if values were removed
    //TODO: Make this throw instead and propagate up?
    mutating func remove(value: Int) throws -> Bool {
        if onlyValue == value {
            //Tried to remove the value that was filled
           throw SudokuSolverError.unsolvable
        }
        let removedValue = possibleValues.remove(value)
        return removedValue != nil
    }
    
}

extension _Cell: CustomStringConvertible {
    var description: String {
        if let value = onlyValue {
            return "<\(value)>"
        }
        return possibleValues.description
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


//fileprivate struct BitMask10 {
//
//    private var _storage: UInt16
//
//    init(allTrue: ()) {
//        self._storage = 0x1111111110
//    }
//
//    subscript(index: Int) -> Bool {
//        get {
//            return ((_storage >> index) & 1) == 1
//        }
//        set {
//            let oldValue = ((_storage >> index) & 1) == 1
//            switch oldValue {
//            case newValue: return
//            case true: _storage = 1 << index ^ _storage
//            case false: _storage = 1 << index | _storage
//            }
//        }
//    }
//
//    func isFinalized() -> Int? {
//        guard _storage && !(_storage & (_storage - 1)) else { return nil }
//    }
//}

