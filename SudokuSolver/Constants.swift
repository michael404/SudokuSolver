struct ConstantsStorage<Type: SudokuType> {
    
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
        
        self.indiciesAffectedByIndex = Type.allCells.map { index in
            var indicies = Set<Int>()
            Self._indiciesInSameRowInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameColumnInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameBoxInclusive(as: index).forEach { indicies.insert($0) }
            //Remove self
            indicies.remove(index)
            //TODO: Consider if sorting is needed for deterministic tests here
            return Array(indicies).sorted()
        }
    
        self.indiciesInSameRowExclusive = Type.allCells.map { index1 in
            Self._indiciesInSameRowInclusive(as: index1).filter { index2 in index1 != index2 }
        }
        
        self.indiciesInSameColumnExclusive = Type.allCells.map { index1 in
            Self._indiciesInSameColumnInclusive(as: index1).filter { index2 in index1 != index2 }
        }
        
        self.indiciesInSameBoxExclusive = Type.allCells.map { index1 in
            Self._indiciesInSameBoxInclusive(as: index1).filter { index2 in index1 != index2 }
        }
            
        self.allIndiciesInRow = Type.allPossibilities.map { row in
            Type.allPossibilities.map { offset in row * Type.possibilities + offset }
        }

        self.allIndiciesInColumn = Type.allPossibilities.map { offset in
            stride(from: 0, to: Type.cells, by: Type.possibilities).map { start in start + offset }
        }
           
        let starts = Self.boxOffsets().map { $0 * Type.sideOfBox }
        self.allIndiciesInBox = starts.map { start in
            Self.boxOffsets().map { offset in start + offset }
        }
    }
    
    private static func _indiciesInSameRowInclusive(as index: Int) -> CountableRange<Int> {
        let start = (index / Type.possibilities) * Type.possibilities
        let end = start + Type.possibilities
        return start..<end
    }
    
    private static func _indiciesInSameColumnInclusive(as index: Int) -> StrideTo<Int> {
        stride(from: index % Type.possibilities, to: Type.cells, by: Type.possibilities)
    }
    
    private static func _indiciesInSameBoxInclusive(as index: Int) -> [Int] {
        let row = index / Type.possibilities
        let column = index % Type.possibilities
        let startIndexOfBlock = (row / Type.sideOfBox) * Type.possibilities * Type.sideOfBox + (column / Type.sideOfBox) * Type.sideOfBox
        return Self.boxOffsets().map { startIndexOfBlock + $0 }
    }
    
    private static func boxOffsets() -> [Int] {
        stride(from: 0, to: Type.possibilities * Type.sideOfBox, by: Type.possibilities)
        .flatMap { $0..<($0 + Type.sideOfBox) }
    }
    
}
