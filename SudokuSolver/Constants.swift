let Constants = ConstantsStorage(size: SudokuSize(sideOfBox: 3))
let Constants16 = ConstantsStorage(size: SudokuSize(sideOfBox: 4))

struct SudokuSize {
    let sideOfBox: Int
    var possibilities: Int { sideOfBox * sideOfBox }
    var allPossibilities: Range<Int> { 0..<possibilities }
    var cells: Int { possibilities * possibilities }
    var allCells: Range<Int> { 0..<cells }
}

struct ConstantsStorage {
    
    /// The 39  indicies that need to be checked when changing an index.
    /// (15 in the same row, 15 in the same column and then 9 remaining in the box)
    /// Laid out as a countinous array of 349indexes. Use the helper
    /// method to access the values.
    let indiciesAffectedByIndex: [[Int]]
    let indiciesInSameRowExclusive: [[Int]]
    let indiciesInSameColumnExclusive: [[Int]]
    let indiciesInSameBoxExclusive: [[Int]]
    let allIndiciesInRow: [[Int]]
    let allIndiciesInColumn: [[Int]]
    let allIndiciesInBox: [[Int]]
    
    init(size: SudokuSize) {

        self.indiciesAffectedByIndex = size.allCells.map { index in
            var indicies = Set<Int>()
            Self._indiciesInSameRowInclusive(as: index, size: size).forEach { indicies.insert($0) }
            Self._indiciesInSameColumnInclusive(as: index, size: size).forEach { indicies.insert($0) }
            Self._indiciesInSameBoxInclusive(as: index, size: size).forEach { indicies.insert($0) }
            //Remove self
            indicies.remove(index)
            //TODO: Consider if sorting is needed for deterministic tests here
            return Array(indicies).sorted()
        }
    
        self.indiciesInSameRowExclusive = size.allCells.map { index1 in
            Self._indiciesInSameRowInclusive(as: index1, size: size).filter { index2 in index1 != index2 }
        }
        
        self.indiciesInSameColumnExclusive = size.allCells.map { index1 in
            Self._indiciesInSameColumnInclusive(as: index1, size: size).filter { index2 in index1 != index2 }
        }
        
        self.indiciesInSameBoxExclusive = size.allCells.map { index1 in
            Self._indiciesInSameBoxInclusive(as: index1, size: size).filter { index2 in index1 != index2 }
        }
            
        self.allIndiciesInRow = size.allPossibilities.map { row in
            size.allPossibilities.map { offset in row * size.possibilities + offset }
        }

        self.allIndiciesInColumn = size.allPossibilities.map { offset in
            stride(from: 0, to: size.cells, by: size.possibilities).map { start in start + offset }
        }
           
        let starts = Self.boxOffsets(size: size).map { $0 * size.sideOfBox }
        self.allIndiciesInBox = starts.map { start in
            Self.boxOffsets(size: size).map { offset in start + offset }
        }
    }
    
    private static func _indiciesInSameRowInclusive(as index: Int, size: SudokuSize) -> CountableRange<Int> {
        let start = (index / size.possibilities) * size.possibilities
        let end = start + size.possibilities
        return start..<end
    }
    
    private static func _indiciesInSameColumnInclusive(as index: Int, size: SudokuSize) -> StrideTo<Int> {
        stride(from: index % size.possibilities, to: size.cells, by: size.possibilities)
    }
    
    private static func _indiciesInSameBoxInclusive(as index: Int, size: SudokuSize) -> [Int] {
        let row = index / size.possibilities
        let column = index % size.possibilities
        let startIndexOfBlock = (row / size.sideOfBox) * size.possibilities * size.sideOfBox + (column / size.sideOfBox) * size.sideOfBox
        return Self.boxOffsets(size: size).map { startIndexOfBlock + $0 }
    }
    
    private static func boxOffsets(size: SudokuSize) -> [Int] {
        stride(from: 0, to: size.possibilities * size.sideOfBox, by: size.possibilities)
        .flatMap { $0..<($0 + size.sideOfBox) }
    }
    
}
