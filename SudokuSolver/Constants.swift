struct ConstantsStorage<SudokuType: SudokuTypeProtocol> {
    
    /// The 39  indicies that need to be checked when changing an index.
    /// (15 in the same row, 15 in the same column and then 9 remaining in the box)
    /// Laid out as a countinous array of 349indexes. Use the helper
    /// method to access the values.
    private let indiciesAffectedByIndex: [[Int]]
    private let indiciesInSameRowExclusive: [[Int]]
    private let indiciesInSameColumnExclusive: [[Int]]
    private let indiciesInSameBoxExclusive: [[Int]]
    private let allIndiciesInRow: [[Int]]
    private let allIndiciesInColumn: [[Int]]
    private let allIndiciesInBox: [[Int]]
    
    init() {
        
        self.indiciesAffectedByIndex = SudokuType.allCells.map { index in
            var indicies = Set<Int>()
            Self._indiciesInSameRowInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameColumnInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameBoxInclusive(as: index).forEach { indicies.insert($0) }
            //Remove self
            indicies.remove(index)
            //TODO: Consider if sorting is needed for deterministic tests here
            return Array(indicies).sorted()
        }
    
        self.indiciesInSameRowExclusive = SudokuType.allCells.map { index1 in
            Self._indiciesInSameRowInclusive(as: index1).filter { index2 in index1 != index2 }
        }
        
        self.indiciesInSameColumnExclusive = SudokuType.allCells.map { index1 in
            Self._indiciesInSameColumnInclusive(as: index1).filter { index2 in index1 != index2 }
        }
        
        self.indiciesInSameBoxExclusive = SudokuType.allCells.map { index1 in
            Self._indiciesInSameBoxInclusive(as: index1).filter { index2 in index1 != index2 }
        }
            
        self.allIndiciesInRow = SudokuType.allPossibilities.map { row in
            SudokuType.allPossibilities.map { offset in row * SudokuType.possibilities + offset }
        }

        self.allIndiciesInColumn = SudokuType.allPossibilities.map { offset in
            stride(from: 0, to: SudokuType.cells, by: SudokuType.possibilities).map { start in start + offset }
        }
           
        let starts = Self.boxOffsets().map { $0 * SudokuType.sideOfBox }
        self.allIndiciesInBox = starts.map { start in
            Self.boxOffsets().map { offset in start + offset }
        }
    }
    
    private static func _indiciesInSameRowInclusive(as index: Int) -> CountableRange<Int> {
        let start = (index / SudokuType.possibilities) * SudokuType.possibilities
        let end = start + SudokuType.possibilities
        return start..<end
    }
    
    private static func _indiciesInSameColumnInclusive(as index: Int) -> StrideTo<Int> {
        stride(from: index % SudokuType.possibilities, to: SudokuType.cells, by: SudokuType.possibilities)
    }
    
    private static func _indiciesInSameBoxInclusive(as index: Int) -> [Int] {
        let row = index / SudokuType.possibilities
        let column = index % SudokuType.possibilities
        let startIndexOfBlock = (row / SudokuType.sideOfBox) * SudokuType.possibilities * SudokuType.sideOfBox + (column / SudokuType.sideOfBox) * SudokuType.sideOfBox
        return Self.boxOffsets().map { startIndexOfBlock + $0 }
    }
    
    private static func boxOffsets() -> [Int] {
        stride(from: 0, to: SudokuType.possibilities * SudokuType.sideOfBox, by: SudokuType.possibilities)
        .flatMap { $0..<($0 + SudokuType.sideOfBox) }
    }
    
    // This function escapes pointers to underlying arrays, since that avoids a lot of ARC overhead
    // We can do this because we know that the whole ConstantsStorage variable is keep alive in a global static variable
    // and that the underlying arrays don't change, but be very carefull when using this method.
    private func unsafeExportHelper(_ i: Int, _ array: [[Int]]) -> UnsafeBufferPointer<Int> {
        assert(array.indices.contains(i))
        return array.withUnsafeBufferPointer {
            return $0[i].withUnsafeBufferPointer {
                return $0
            }
        }
    }
    
    func allIndiciesInRow(_ i: Int) -> UnsafeBufferPointer<Int> {
        unsafeExportHelper(i, allIndiciesInRow)
    }
    
    func allIndiciesInColumn(_ i: Int) -> UnsafeBufferPointer<Int> {
        unsafeExportHelper(i, allIndiciesInColumn)
    }
    
    func allIndiciesInBox(_ i: Int) -> UnsafeBufferPointer<Int> {
        unsafeExportHelper(i, allIndiciesInBox)
    }
    
    func indiciesAffectedByIndex(_ i: Int) -> UnsafeBufferPointer<Int> {
        unsafeExportHelper(i, indiciesAffectedByIndex)
    }
    
    func indiciesInSameRowExclusive(_ i: Int) -> UnsafeBufferPointer<Int> {
        unsafeExportHelper(i, indiciesInSameRowExclusive)
    }
    
    func indiciesInSameColumnExclusive(_ i: Int) -> UnsafeBufferPointer<Int> {
        unsafeExportHelper(i, indiciesInSameColumnExclusive)
    }
    
    func indiciesInSameBoxExclusive(_ i: Int) -> UnsafeBufferPointer<Int> {
        unsafeExportHelper(i, indiciesInSameBoxExclusive)
    }
    
}
