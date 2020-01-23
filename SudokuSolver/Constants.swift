let Constants = ConstantsStorage<SudokuSize9>()
let Constants16 = ConstantsStorage<SudokuSize16>()

protocol SudokuSize {
    static var sideOfBox: Int { get }
}

extension SudokuSize {
    static var possibilities: Int { sideOfBox * sideOfBox }
    static var allPossibilities: Range<Int> { 0..<possibilities }
    static var cells: Int { possibilities * possibilities }
    static var allCells: Range<Int> { 0..<cells }
}

enum SudokuSize9: SudokuSize {
    static let sideOfBox: Int = 3
}

enum SudokuSize16: SudokuSize {
    static let sideOfBox: Int = 4
}


struct ConstantsStorage<Size: SudokuSize> {
    
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
    
    init() {

        self.indiciesAffectedByIndex = Size.allCells.map { index in
            var indicies = Set<Int>()
            Self._indiciesInSameRowInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameColumnInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameBoxInclusive(as: index).forEach { indicies.insert($0) }
            //Remove self
            indicies.remove(index)
            //TODO: Consider if sorting is needed for deterministic tests here
            return Array(indicies).sorted()
        }
    
        self.indiciesInSameRowExclusive = Size.allCells.map { index1 in
            Self._indiciesInSameRowInclusive(as: index1).filter { index2 in index1 != index2 }
        }
        
        self.indiciesInSameColumnExclusive = Size.allCells.map { index1 in
            Self._indiciesInSameColumnInclusive(as: index1).filter { index2 in index1 != index2 }
        }
        
        self.indiciesInSameBoxExclusive = Size.allCells.map { index1 in
            Self._indiciesInSameBoxInclusive(as: index1).filter { index2 in index1 != index2 }
        }
            
        self.allIndiciesInRow = Size.allPossibilities.map { row in
            Size.allPossibilities.map { offset in row * Size.possibilities + offset }
        }

        self.allIndiciesInColumn = Size.allPossibilities.map { offset in
            stride(from: 0, to: Size.cells, by: Size.possibilities).map { start in start + offset }
        }
           
        let starts = Self.boxOffsets.map { $0 * Size.sideOfBox }
        self.allIndiciesInBox = starts.map { start in
            Self.boxOffsets.map { offset in start + offset }
        }
    }
    
    private static func _indiciesInSameRowInclusive(as index: Int) -> CountableRange<Int> {
        let start = (index / Size.possibilities) * Size.possibilities
        let end = start + Size.possibilities
        return start..<end
    }
    
    private static func _indiciesInSameColumnInclusive(as index: Int) -> StrideTo<Int> {
        stride(from: index % Size.possibilities, to: Size.cells, by: Size.possibilities)
    }
    
    private static func _indiciesInSameBoxInclusive(as index: Int) -> [Int] {
        let row = index / Size.possibilities
        let column = index % Size.possibilities
        let startIndexOfBlock = (row / Size.sideOfBox) * Size.possibilities * Size.sideOfBox + (column / Size.sideOfBox) * Size.sideOfBox
        return Self.boxOffsets.map { startIndexOfBlock + $0 }
    }
    
    private static var boxOffsets: [Int] {
        stride(from: 0, to: Size.possibilities * Size.sideOfBox, by: Size.possibilities)
        .flatMap { $0..<($0 + Size.sideOfBox) }
    }
    
}
