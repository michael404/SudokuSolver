extension SudokuBoard {
    
    func findFirstSolutionAlt() throws -> SudokuBoard {

        // Returns true once the function has found a solution
        func _solve(_ board: CellOptionBoard, _ indicies: [Int], _ lastChangedIndex: Int = 0) throws -> CellOptionBoard {

            var board = board
            
            //TODO: figure out why this does not improve performance
            if lastChangedIndex == 0 {
                try board.eliminatePossibilities(for: CollectionOfOne(lastChangedIndex))
            } else {
                try board.eliminatePossibilities(for: 0..<81)
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
    
    //TODO: Try replacing this with a FixedCellArray81
    var board: [_Cell]
    
    init(_ board: SudokuBoard) {
        self.board = board.map { cell in
            return cell == nil ? _Cell() : _Cell(cell.value)
        }
        
    }
    
    // Throws if we are in an impossible situation
    mutating func eliminatePossibilities<C: Collection>(for indicies: C) throws {
        
        var updatedIndicies = Set<Int>()
        for index in indices {
            if let valueToRemove = board[index].onlyValue {
                for indexToRemoveFrom in CellOptionBoard.indiciesToRemoveFrom[index] {
                    if try board[indexToRemoveFrom].remove(value: valueToRemove) {
                        updatedIndicies.insert(indexToRemoveFrom)
                    }
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


struct OneToNineSet: Sequence {
    
    private var _storage: UInt16
    
    private var _count: UInt8
    
    //TODO: Evaluate if this cache is necessary after other performance optimizations
    /// The only value if there is only one value. 0 otherwise
    fileprivate var _onlyValue: UInt8
    
    init(allTrue: ()) {
        self._storage = 0b1111111110
        self._count = 9
        self._onlyValue = 0
    }
    
    init(_ value: Int) {
        assert((1...9).contains(value))
        self._storage = 1 << value ^ 0
        self._count = 1
        self._onlyValue = numericCast(value)
    }

    func contains(_ value: Int) -> Bool {
        assert((1...9).contains(value))
        return ((_storage >> value) & 1) == 1
    }
    
    //Returns true if a value was removed
    mutating func remove(_ value: Int) -> Bool {
        assert((1...9).contains(value))
        let oldValue = ((_storage >> value) & 1) == 1
        if oldValue {
            _storage = 1 << value ^ _storage
            _count = _count &- 1
            if _count == 1 {
                for index in 1...9 where contains(index) {
                    _onlyValue = numericCast(index)
                }
            }
            return true
        }
        return false
    }
    
    var count: Int {
        return numericCast(_count)
    }

    var hasSingeValue: Bool {
        return _count == 1
    }
    
    var onlyValue: Int? {
        guard _onlyValue != 0 else { return nil }
        return numericCast(_onlyValue)
    }
    
    func makeIterator() -> OneToNineIterator {
        return OneToNineIterator(self)
    }
}

struct OneToNineIterator: IteratorProtocol {
        
    var base: OneToNineSet
    private var index = 1
    
    init(_ base: OneToNineSet) { self.base = base }
    
    mutating func next() -> Int? {
        
        guard index < 10 else { return nil }
        
        if base.hasSingeValue {
            index = 10
            return numericCast(base._onlyValue)
        }
        
        repeat {
            defer { index = index &+ 1 }
            if base.contains(index) { return index }
        } while index < 10
        
        return nil
    }
    
}
