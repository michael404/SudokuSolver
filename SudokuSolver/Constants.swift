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
    private struct ImmortalIndexTable<Element: FixedWidthInteger & UnsignedInteger>: @unchecked Sendable {

        private let base: UnsafePointer<Element>
        private let rowWidth: Int
        private let rowCount: Int

        init(_ rows: [[Int]]) {
            let rowWidth = rows.first?.count ?? 0
            precondition(rowWidth > 0, "Table must not be empty")
            precondition(rows.allSatisfy { $0.count == rowWidth },
                         "All rows in a table must have the same length")
            // The narrowest element type that fits keeps the hot tables
            // cache-resident: the solver's inner loops are dominated by
            // walks over these tables.
            let flattened = rows.flatMap { $0 }.map { value -> Element in
                precondition(value >= 0 && value <= Int(Element.max), "Value \(value) out of range")
                return Element(value)
            }
            let storage = UnsafeMutableBufferPointer<Element>.allocate(capacity: flattened.count)
            _ = storage.initialize(from: flattened)
            self.base = UnsafePointer(storage.baseAddress!)
            self.rowWidth = rowWidth
            self.rowCount = rows.count
        }

        subscript(row: Int) -> UnsafeBufferPointer<Element> {
            assert((0..<rowCount).contains(row), "Row \(row) out of bounds")
            return UnsafeBufferPointer(start: base + row * rowWidth, count: rowWidth)
        }

    }

    /// The per-cell-index tables, stored as the smallest type that fits this
    /// board's indices.
    private typealias IndexTable = ImmortalIndexTable<SudokuType.IndexStorage>

    /// The peer indices that need to be checked after solving a cell:
    /// the other cells in the same row, column, and box.
    private let indicesAffectedByIndexTable: IndexTable
    private let indicesInSameRowExclusiveTable: IndexTable
    private let indicesInSameColumnExclusiveTable: IndexTable
    private let indicesInSameBoxExclusiveTable: IndexTable
    private let allIndicesInRowTable: IndexTable
    private let allIndicesInColumnTable: IndexTable
    private let allIndicesInBoxTable: IndexTable
    /// For each cell index: its row, column and box packed into one value
    /// (row in bits 0-4, column in bits 5-9, box in bits 10-14), for cheap
    /// dirty-unit marking in the solver. Needs 15 bits, so it is not stored
    /// as `IndexStorage`.
    private let packedUnitIDsTable: ImmortalIndexTable<UInt16>

    init() {

        self.indicesAffectedByIndexTable = ImmortalIndexTable(SudokuType.allCells.map { index in
            var indices = Set<Int>()
            Self._indicesInSameRowInclusive(as: index).forEach { indices.insert($0) }
            Self._indicesInSameColumnInclusive(as: index).forEach { indices.insert($0) }
            Self._indicesInSameBoxInclusive(as: index).forEach { indices.insert($0) }
            // Remove self
            indices.remove(index)
            return Array(indices).sorted()
        })

        self.indicesInSameRowExclusiveTable = ImmortalIndexTable(SudokuType.allCells.map { index1 in
            Self._indicesInSameRowInclusive(as: index1).filter { index2 in index1 != index2 }
        })

        self.indicesInSameColumnExclusiveTable = ImmortalIndexTable(SudokuType.allCells.map { index1 in
            Self._indicesInSameColumnInclusive(as: index1).filter { index2 in index1 != index2 }
        })

        self.indicesInSameBoxExclusiveTable = ImmortalIndexTable(SudokuType.allCells.map { index1 in
            Self._indicesInSameBoxInclusive(as: index1).filter { index2 in index1 != index2 }
        })

        self.allIndicesInRowTable = ImmortalIndexTable(SudokuType.allPossibilities.map { row in
            SudokuType.allPossibilities.map { offset in row * SudokuType.possibilities + offset }
        })

        self.allIndicesInColumnTable = ImmortalIndexTable(SudokuType.allPossibilities.map { offset in
            stride(from: 0, to: SudokuType.cells, by: SudokuType.possibilities).map { start in start + offset }
        })

        let starts = Self.boxOffsets().map { $0 * SudokuType.sideOfBox }
        self.allIndicesInBoxTable = ImmortalIndexTable(starts.map { start in
            Self.boxOffsets().map { offset in start + offset }
        })

        self.packedUnitIDsTable = ImmortalIndexTable([SudokuType.allCells.map { index in
            let row = index / SudokuType.possibilities
            let column = index % SudokuType.possibilities
            let box = (row / SudokuType.sideOfBox) * SudokuType.sideOfBox + column / SudokuType.sideOfBox
            return row | (column << 5) | (box << 10)
        }])
    }

    private static func _indicesInSameRowInclusive(as index: Int) -> CountableRange<Int> {
        let start = (index / SudokuType.possibilities) * SudokuType.possibilities
        let end = start + SudokuType.possibilities
        return start..<end
    }

    private static func _indicesInSameColumnInclusive(as index: Int) -> StrideTo<Int> {
        stride(from: index % SudokuType.possibilities, to: SudokuType.cells, by: SudokuType.possibilities)
    }

    private static func _indicesInSameBoxInclusive(as index: Int) -> [Int] {
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

    func allIndicesInRow(_ i: Int) -> UnsafeBufferPointer<SudokuType.IndexStorage> {
        allIndicesInRowTable[i]
    }

    func allIndicesInColumn(_ i: Int) -> UnsafeBufferPointer<SudokuType.IndexStorage> {
        allIndicesInColumnTable[i]
    }

    func allIndicesInBox(_ i: Int) -> UnsafeBufferPointer<SudokuType.IndexStorage> {
        allIndicesInBoxTable[i]
    }

    func indicesAffectedByIndex(_ i: Int) -> UnsafeBufferPointer<SudokuType.IndexStorage> {
        indicesAffectedByIndexTable[i]
    }

    func indicesInSameRowExclusive(_ i: Int) -> UnsafeBufferPointer<SudokuType.IndexStorage> {
        indicesInSameRowExclusiveTable[i]
    }

    func indicesInSameColumnExclusive(_ i: Int) -> UnsafeBufferPointer<SudokuType.IndexStorage> {
        indicesInSameColumnExclusiveTable[i]
    }

    func indicesInSameBoxExclusive(_ i: Int) -> UnsafeBufferPointer<SudokuType.IndexStorage> {
        indicesInSameBoxExclusiveTable[i]
    }

    func packedUnitIDs() -> UnsafeBufferPointer<UInt16> {
        packedUnitIDsTable[0]
    }

}
