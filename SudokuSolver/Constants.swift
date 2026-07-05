struct ConstantsStorage<SudokuType: SudokuTypeProtocol>: Sendable {

    // `@unchecked Sendable` because of the `UnsafePointer` property: the pointed-to
    // memory is immutable after init and never deallocated, so sharing across
    // threads is safe.
    /// A table of precalculated index rows, where all rows have the same length,
    /// backed by a single flat buffer that is allocated once and intentionally
    /// never deallocated.
    ///
    /// The solver's hot loops read these tables through `UnsafeBufferPointer`s to
    /// avoid ARC and bounds-checking overhead. Escaping a pointer out of
    /// `Array.withUnsafeBufferPointer` (the previous approach) is undefined
    /// behavior even if the array is kept alive elsewhere, so instead the rows
    /// are copied into a manually allocated buffer that is never deallocated.
    /// Reading through pointers into that buffer is well-defined for the
    /// lifetime of the program.
    ///
    /// Since the backing memory is deliberately leaked, values of this type must
    /// only be stored in variables that live for the whole program, like the
    /// `constants` static properties on the Sudoku types.
    private struct ImmortalIndexTable: @unchecked Sendable {

        private let base: UnsafePointer<Int>
        private let rowWidth: Int
        private let rowCount: Int

        init(_ rows: [[Int]]) {
            let rowWidth = rows.first?.count ?? 0
            precondition(rowWidth > 0, "Table must not be empty")
            precondition(rows.allSatisfy { $0.count == rowWidth },
                         "All rows in a table must have the same length")
            let flattened = rows.flatMap { $0 }
            let storage = UnsafeMutableBufferPointer<Int>.allocate(capacity: flattened.count)
            _ = storage.initialize(from: flattened)
            self.base = UnsafePointer(storage.baseAddress!)
            self.rowWidth = rowWidth
            self.rowCount = rows.count
        }

        subscript(row: Int) -> UnsafeBufferPointer<Int> {
            assert((0..<rowCount).contains(row), "Row \(row) out of bounds")
            return UnsafeBufferPointer(start: base + row * rowWidth, count: rowWidth)
        }

    }

    /// The indicies that need to be checked when changing an index:
    /// the other indicies in the same row, in the same column, and the
    /// remaining indicies in the same box.
    private let indiciesAffectedByIndexTable: ImmortalIndexTable
    private let indiciesInSameRowExclusiveTable: ImmortalIndexTable
    private let indiciesInSameColumnExclusiveTable: ImmortalIndexTable
    private let indiciesInSameBoxExclusiveTable: ImmortalIndexTable
    private let allIndiciesInRowTable: ImmortalIndexTable
    private let allIndiciesInColumnTable: ImmortalIndexTable
    private let allIndiciesInBoxTable: ImmortalIndexTable

    init() {

        self.indiciesAffectedByIndexTable = ImmortalIndexTable(SudokuType.allCells.map { index in
            var indicies = Set<Int>()
            Self._indiciesInSameRowInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameColumnInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameBoxInclusive(as: index).forEach { indicies.insert($0) }
            // Remove self
            indicies.remove(index)
            return Array(indicies).sorted()
        })

        self.indiciesInSameRowExclusiveTable = ImmortalIndexTable(SudokuType.allCells.map { index1 in
            Self._indiciesInSameRowInclusive(as: index1).filter { index2 in index1 != index2 }
        })

        self.indiciesInSameColumnExclusiveTable = ImmortalIndexTable(SudokuType.allCells.map { index1 in
            Self._indiciesInSameColumnInclusive(as: index1).filter { index2 in index1 != index2 }
        })

        self.indiciesInSameBoxExclusiveTable = ImmortalIndexTable(SudokuType.allCells.map { index1 in
            Self._indiciesInSameBoxInclusive(as: index1).filter { index2 in index1 != index2 }
        })

        self.allIndiciesInRowTable = ImmortalIndexTable(SudokuType.allPossibilities.map { row in
            SudokuType.allPossibilities.map { offset in row * SudokuType.possibilities + offset }
        })

        self.allIndiciesInColumnTable = ImmortalIndexTable(SudokuType.allPossibilities.map { offset in
            stride(from: 0, to: SudokuType.cells, by: SudokuType.possibilities).map { start in start + offset }
        })

        let starts = Self.boxOffsets().map { $0 * SudokuType.sideOfBox }
        self.allIndiciesInBoxTable = ImmortalIndexTable(starts.map { start in
            Self.boxOffsets().map { offset in start + offset }
        })
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
        let startIndexOfBlock =
            (row / SudokuType.sideOfBox) * SudokuType.possibilities * SudokuType.sideOfBox
                + (column / SudokuType.sideOfBox) * SudokuType.sideOfBox
        return Self.boxOffsets().map { startIndexOfBlock + $0 }
    }

    private static func boxOffsets() -> [Int] {
        stride(from: 0, to: SudokuType.possibilities * SudokuType.sideOfBox, by: SudokuType.possibilities)
        .flatMap { $0..<($0 + SudokuType.sideOfBox) }
    }

    func allIndiciesInRow(_ i: Int) -> UnsafeBufferPointer<Int> {
        allIndiciesInRowTable[i]
    }

    func allIndiciesInColumn(_ i: Int) -> UnsafeBufferPointer<Int> {
        allIndiciesInColumnTable[i]
    }

    func allIndiciesInBox(_ i: Int) -> UnsafeBufferPointer<Int> {
        allIndiciesInBoxTable[i]
    }

    func indiciesAffectedByIndex(_ i: Int) -> UnsafeBufferPointer<Int> {
        indiciesAffectedByIndexTable[i]
    }

    func indiciesInSameRowExclusive(_ i: Int) -> UnsafeBufferPointer<Int> {
        indiciesInSameRowExclusiveTable[i]
    }

    func indiciesInSameColumnExclusive(_ i: Int) -> UnsafeBufferPointer<Int> {
        indiciesInSameColumnExclusiveTable[i]
    }

    func indiciesInSameBoxExclusive(_ i: Int) -> UnsafeBufferPointer<Int> {
        indiciesInSameBoxExclusiveTable[i]
    }

}
