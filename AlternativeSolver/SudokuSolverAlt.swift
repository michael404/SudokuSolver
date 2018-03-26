extension SudokuBoard {
    
    func findFirstSolutionAlt() throws -> SudokuBoard {

        // Returns true once the function has found a solution
        func _solve(_ board: CellOptionBoard, _ indicies: [Int], _ lastChangedIndex: Int = 0) throws -> CellOptionBoard {

            var board = board
            
            //TODO: figure out why this does not improve performance
            if lastChangedIndex == 0 {
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

fileprivate struct CellOptionBoard {
    
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

extension CellOptionBoard {
    
    private static var indiciesToRemoveFrom: [[Int]] = [[10, 20, 5, 7, 27, 45, 63, 3, 11, 54, 72, 19, 2, 4, 9, 18, 6, 36, 8, 1], [10, 20, 55, 5, 7, 0, 3, 37, 11, 19, 2, 4, 28, 46, 6, 64, 73, 9, 18, 8], [65, 10, 20, 38, 5, 7, 29, 74, 0, 11, 3, 56, 19, 47, 18, 4, 9, 6, 8, 1], [12, 75, 14, 30, 23, 5, 7, 48, 0, 13, 22, 2, 4, 21, 39, 6, 57, 66, 8, 1], [12, 23, 14, 49, 40, 5, 7, 0, 3, 13, 76, 58, 22, 2, 21, 67, 31, 6, 8, 1], [12, 41, 23, 14, 77, 7, 68, 0, 3, 13, 32, 22, 59, 2, 4, 21, 6, 50, 8, 1], [17, 25, 5, 7, 15, 24, 78, 0, 33, 3, 42, 16, 2, 4, 51, 60, 26, 69, 8, 1], [79, 17, 25, 5, 15, 52, 24, 43, 0, 3, 16, 70, 2, 4, 34, 6, 26, 61, 8, 1], [17, 25, 5, 7, 15, 71, 24, 0, 3, 16, 2, 4, 53, 44, 6, 26, 62, 35, 1, 80], [12, 17, 10, 14, 20, 27, 15, 45, 63, 0, 11, 13, 16, 54, 72, 19, 18, 2, 36, 1], [12, 17, 14, 20, 55, 15, 0, 11, 13, 16, 37, 19, 28, 9, 64, 46, 2, 18, 73, 1], [12, 17, 10, 14, 20, 65, 38, 74, 15, 29, 56, 0, 13, 16, 19, 47, 2, 9, 18, 1], [17, 10, 14, 30, 75, 23, 5, 15, 48, 3, 11, 13, 16, 22, 21, 9, 39, 4, 57, 66], [12, 17, 10, 14, 23, 49, 40, 5, 15, 3, 11, 76, 16, 58, 22, 21, 9, 4, 31, 67], [12, 17, 10, 41, 23, 77, 5, 15, 68, 3, 11, 13, 16, 32, 22, 59, 21, 9, 4, 50], [12, 17, 10, 14, 25, 7, 78, 24, 33, 11, 16, 13, 42, 51, 9, 60, 6, 26, 69, 8], [12, 17, 10, 14, 25, 15, 7, 52, 43, 24, 11, 13, 70, 9, 34, 6, 26, 61, 8, 79], [12, 10, 14, 25, 15, 7, 71, 24, 11, 13, 16, 62, 9, 53, 44, 6, 26, 35, 8, 80], [23, 25, 20, 10, 27, 24, 45, 0, 63, 54, 72, 11, 19, 22, 2, 21, 9, 36, 26, 1], [23, 25, 20, 10, 55, 24, 0, 11, 37, 22, 18, 21, 28, 46, 64, 26, 73, 2, 9, 1], [65, 23, 25, 10, 38, 74, 29, 24, 56, 11, 0, 19, 22, 18, 21, 2, 47, 9, 26, 1], [12, 23, 25, 20, 30, 75, 14, 5, 24, 48, 3, 13, 19, 22, 18, 4, 39, 57, 26, 66], [12, 23, 25, 20, 49, 40, 14, 5, 24, 3, 13, 76, 58, 19, 18, 21, 4, 31, 67, 26], [12, 41, 25, 14, 20, 77, 5, 68, 24, 3, 13, 32, 19, 22, 18, 21, 59, 4, 26, 50], [17, 23, 25, 20, 15, 78, 7, 33, 42, 16, 19, 22, 18, 21, 51, 60, 6, 26, 69, 8], [17, 23, 20, 7, 52, 24, 43, 15, 16, 70, 19, 22, 18, 21, 34, 6, 26, 61, 8, 79], [17, 23, 25, 20, 7, 15, 24, 71, 16, 19, 22, 18, 21, 53, 44, 62, 6, 35, 8, 80], [30, 38, 29, 45, 63, 0, 33, 54, 32, 72, 37, 47, 28, 9, 18, 31, 34, 36, 46, 35], [10, 30, 55, 38, 27, 29, 45, 33, 37, 32, 19, 47, 64, 31, 34, 46, 73, 36, 35, 1], [65, 30, 20, 38, 27, 74, 45, 56, 33, 11, 32, 37, 47, 28, 2, 31, 34, 36, 46, 35], [12, 41, 75, 49, 40, 27, 29, 48, 3, 33, 32, 28, 21, 39, 31, 34, 57, 50, 66, 35], [41, 30, 49, 40, 27, 29, 48, 33, 13, 32, 58, 22, 76, 28, 4, 67, 39, 34, 50, 35], [41, 23, 14, 30, 77, 40, 49, 27, 5, 29, 68, 48, 33, 59, 28, 39, 31, 34, 50, 35], [30, 27, 15, 29, 24, 78, 43, 52, 42, 32, 28, 51, 60, 31, 34, 6, 69, 44, 35, 53], [25, 30, 27, 7, 29, 52, 43, 33, 42, 32, 16, 70, 28, 51, 53, 31, 44, 61, 35, 79], [17, 30, 27, 29, 71, 43, 52, 33, 42, 32, 28, 53, 62, 31, 34, 26, 44, 51, 8, 80], [41, 40, 38, 27, 29, 45, 43, 0, 63, 42, 37, 54, 72, 47, 18, 9, 39, 44, 46, 28], [41, 10, 55, 40, 38, 27, 29, 45, 43, 42, 19, 47, 28, 64, 39, 44, 36, 46, 73, 1], [41, 65, 20, 40, 74, 27, 29, 45, 43, 56, 11, 42, 37, 47, 2, 28, 39, 44, 36, 46], [12, 41, 75, 30, 49, 40, 38, 43, 3, 48, 42, 37, 32, 21, 44, 36, 57, 31, 66, 50], [41, 30, 49, 38, 43, 48, 42, 13, 37, 22, 58, 76, 4, 39, 44, 36, 31, 67, 32, 50], [23, 14, 77, 30, 40, 38, 5, 68, 49, 43, 48, 42, 37, 32, 59, 39, 44, 36, 50, 31], [41, 40, 38, 15, 78, 24, 43, 52, 33, 37, 51, 53, 39, 44, 36, 6, 60, 69, 34, 35], [41, 25, 40, 38, 7, 52, 33, 42, 16, 37, 70, 51, 53, 39, 44, 36, 34, 61, 35, 79], [41, 17, 40, 38, 52, 71, 43, 33, 42, 37, 62, 53, 39, 51, 36, 26, 34, 35, 8, 80], [49, 38, 27, 52, 29, 48, 0, 63, 54, 72, 37, 47, 51, 53, 9, 46, 18, 50, 36, 28], [10, 49, 55, 38, 27, 52, 45, 48, 29, 37, 19, 47, 51, 53, 28, 64, 36, 50, 73, 1], [65, 20, 49, 38, 74, 27, 52, 45, 48, 29, 11, 56, 37, 51, 53, 2, 46, 28, 50, 36], [12, 41, 75, 30, 49, 40, 52, 45, 3, 32, 47, 51, 53, 21, 46, 39, 50, 57, 66, 31], [41, 30, 40, 52, 45, 48, 13, 76, 58, 22, 47, 51, 53, 4, 46, 31, 50, 67, 32, 39], [41, 23, 14, 77, 49, 30, 40, 5, 68, 52, 45, 48, 32, 47, 51, 53, 59, 46, 31, 39], [49, 15, 52, 45, 48, 24, 33, 42, 78, 43, 47, 53, 60, 46, 6, 50, 69, 34, 35, 44], [25, 49, 7, 45, 48, 43, 33, 42, 16, 70, 47, 51, 53, 46, 34, 50, 61, 44, 35, 79], [17, 49, 52, 45, 48, 71, 33, 42, 43, 47, 51, 62, 46, 44, 50, 26, 34, 35, 8, 80], [65, 55, 74, 27, 45, 63, 56, 0, 72, 58, 59, 62, 9, 60, 18, 57, 36, 61, 64, 73], [65, 10, 74, 63, 56, 54, 37, 58, 19, 59, 62, 28, 60, 46, 57, 64, 61, 73, 72, 1], [65, 20, 55, 38, 74, 29, 63, 11, 54, 72, 58, 59, 62, 2, 60, 47, 57, 64, 61, 73], [12, 75, 30, 55, 77, 68, 48, 56, 3, 54, 76, 58, 59, 62, 21, 60, 39, 67, 61, 66], [75, 77, 55, 40, 49, 68, 56, 13, 54, 76, 22, 59, 62, 4, 60, 31, 57, 67, 61, 66], [41, 23, 14, 77, 55, 75, 5, 68, 56, 54, 32, 58, 76, 62, 60, 67, 57, 50, 61, 66], [80, 55, 15, 78, 24, 71, 56, 33, 54, 42, 58, 70, 59, 62, 51, 57, 6, 61, 69, 79], [80, 25, 55, 7, 52, 71, 43, 56, 78, 54, 16, 58, 70, 59, 62, 60, 34, 57, 69, 79], [79, 17, 55, 78, 71, 56, 54, 58, 70, 59, 53, 60, 44, 57, 26, 61, 69, 35, 8, 80], [65, 55, 74, 27, 68, 71, 45, 0, 56, 54, 72, 70, 64, 9, 67, 18, 36, 69, 66, 73], [65, 10, 55, 74, 68, 71, 63, 56, 37, 54, 70, 19, 72, 28, 67, 46, 69, 66, 73, 1], [20, 55, 38, 74, 68, 29, 71, 63, 56, 11, 54, 72, 70, 47, 64, 2, 67, 69, 66, 73], [12, 65, 75, 30, 77, 68, 71, 63, 3, 48, 76, 70, 58, 59, 64, 21, 67, 39, 57, 69], [65, 75, 77, 49, 40, 68, 71, 63, 13, 76, 70, 22, 58, 64, 4, 59, 31, 57, 69, 66], [65, 23, 14, 41, 77, 75, 5, 71, 63, 76, 32, 70, 58, 59, 64, 67, 57, 50, 69, 66], [80, 65, 68, 15, 71, 63, 24, 33, 42, 78, 70, 64, 51, 67, 60, 6, 62, 61, 66, 79], [80, 65, 25, 68, 7, 71, 63, 43, 52, 78, 16, 64, 62, 67, 34, 60, 69, 66, 61, 79], [61, 65, 17, 79, 68, 78, 63, 70, 64, 53, 67, 44, 62, 26, 69, 66, 35, 60, 8, 80], [80, 65, 75, 77, 55, 74, 27, 78, 45, 63, 0, 56, 76, 54, 18, 9, 64, 36, 73, 79], [80, 65, 75, 10, 77, 55, 74, 78, 63, 56, 76, 72, 37, 19, 54, 28, 64, 46, 1, 79], [80, 65, 75, 77, 20, 55, 38, 78, 29, 63, 56, 11, 76, 72, 54, 47, 2, 64, 73, 79], [80, 12, 77, 30, 74, 78, 68, 48, 3, 76, 72, 58, 59, 21, 39, 67, 57, 73, 66, 79], [80, 75, 77, 49, 40, 74, 78, 68, 13, 72, 58, 22, 59, 4, 67, 31, 57, 73, 66, 79], [80, 41, 75, 14, 23, 74, 5, 78, 68, 76, 72, 32, 58, 59, 67, 57, 50, 73, 66, 79], [80, 75, 77, 74, 15, 24, 71, 33, 76, 72, 42, 70, 51, 62, 60, 6, 73, 69, 61, 79], [75, 25, 77, 74, 78, 7, 52, 43, 71, 76, 72, 16, 70, 62, 60, 34, 73, 61, 69, 80], [17, 75, 77, 74, 78, 71, 76, 72, 70, 62, 53, 60, 44, 26, 73, 61, 35, 69, 8, 79]]
    
//    private static var indiciesToRemoveFrom: [[Int]] = {
//        var result: [[Int]] = []
//        for index in 0..<81 {
//            var indicies = Set<Int>()
//            indiciesInSameRow(as: index).forEach { indicies.insert($0) }
//            indiciesInSameColumn(as: index).forEach { indicies.insert($0) }
//            indiciesInSameBox(as: index).forEach { indicies.insert($0) }
//            //Remove self
//            indicies.remove(index)
//            result.append(Array(indicies))
//        }
//        print(result)
//        return result
//    }()
//
//    private static func indiciesInSameRow(as index: Int) -> Range<Int> {
//        let start = (index / 9) * 9
//        let end = start + 9
//        return start..<end
//    }
//
//    private static func indiciesInSameColumn(as index: Int) -> StrideTo<Int> {
//        let start = index % 9
//        return stride(from: start, to: 81, by: 9)
//    }
//
//    private static func indiciesInSameBox(as index: Int) -> [Int] {
//        //TODO: This can probably be simplified
//        let row = index / 9
//        let column = index % 9
//        var startIndexOfBlock: Int
//        switch row {
//        case 0...2: startIndexOfBlock = 0
//        case 3...5: startIndexOfBlock = 27
//        case 6...8: startIndexOfBlock = 54
//        default: preconditionFailure()
//        }
//        switch column {
//        case 3...5: startIndexOfBlock += 3
//        case 6...8: startIndexOfBlock += 6
//        default: break
//        }
//        return [0,1,2,9,10,11,18,19,20].map { startIndexOfBlock + $0 }
//    }
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
