extension SudokuBoard {
    
    func findFirstSolution() -> SudokuBoard? {
        var rng = WyRand()
        return findFirstSolution(using: &rng)
    }
    
    func findFirstSolution<R: RNG>(using rng: inout R) -> SudokuBoard? {
        guard var solver = SudokuSolver(eliminating: self, rng: rng) else { return nil }
        defer { rng = solver.rng }
        let solutions = solver.solve(transformation: Normal.self, maxSolutions: 1)
        return solutions.first
    }
    
    func findAllSolutions() -> [SudokuBoard] {
        var rng = WyRand()
        return findAllSolutions(using: &rng)
    }
    
    func findAllSolutions<R: RNG>(using rng: inout R) -> [SudokuBoard] {
        guard var solver = SudokuSolver(eliminating: self, rng: rng) else { return [] }
        defer { rng = solver.rng }
        let solutions = solver.solve(transformation: Normal.self, maxSolutions: Int.max)
        return solutions
    }
    
    static func randomFullyFilledBoard() -> SudokuBoard {
        var rng = WyRand()
        return randomFullyFilledBoard(using: &rng)
    }
    
    static func randomFullyFilledBoard<R: RNG>(using rng: inout R) -> SudokuBoard {
        guard var solver = SudokuSolver(eliminating: SudokuBoard.empty, rng: rng) else {
            fatalError("Inconsistent state")
        }
        defer { rng = solver.rng }
        return solver.solve(transformation: Shuffle.self, maxSolutions: 1).first!
    }
    
    enum NumberOfSolutions { case none, one, multiple }
    
    func numberOfSolutions() -> NumberOfSolutions {
        var rng = WyRand()
        return numberOfSolutions(using: &rng)
    }
    
    func numberOfSolutions<R: RNG>(using rng: inout R) -> NumberOfSolutions {
        guard var solver = SudokuSolver(eliminating: self, rng: rng) else { return .none }
        defer { rng = solver.rng }
        let solutions = solver.solve(transformation: Normal.self, maxSolutions: 2)
        switch solutions.count {
        case 0: return .none
        case 1: return .one
        default: return .multiple
        }
    }
}

struct SudokuSolver<SudokuType: SudokuTypeProtocol, R: RNG> {
    
    typealias Board = SudokuBoard<SudokuType>
    typealias Cell = SudokuCell<SudokuType>
    var board: Board
    var rng: R

    // Units whose cells lost candidates since the last deduction sweep. The sweeps
    // only revisit dirty units: a unit whose cells are unchanged since it was last
    // swept cannot yield new deductions. Starts all-dirty so the first sweep after
    // init covers the whole board.
    private var dirtyRows = Self.allUnitsDirty
    private var dirtyColumns = Self.allUnitsDirty
    private var dirtyBoxes = Self.allUnitsDirty

    private static var allUnitsDirty: UInt32 { (1 << SudokuType.possibilities) - 1 }

    @inline(__always)
    private mutating func markDirty(_ index: Int) {
        // Row in bits 0-4, column in bits 5-9, box in bits 10-14.
        let packed = UInt32(SudokuType.constants.packedUnitIDs()[index])
        dirtyRows |= 1 &<< (packed & 31)
        dirtyColumns |= 1 &<< ((packed &>> 5) & 31)
        dirtyBoxes |= 1 &<< ((packed &>> 10) & 31)
    }

    init?(eliminating board: Board, rng: R) {
        self.board = board
        self.rng = rng
        // Iterates the unmodified `board` parameter so that only the originally
        // solved cells trigger elimination, as cascades solve more cells as we go.
        for index in SudokuType.allCells where board[index].isSolved {
            guard eliminatePossibilities(basedOnSolvedIndex: index) else { return nil }
        }
    }
    
    mutating func solve<T: SudokuCellTransformation>(transformation: T.Type, maxSolutions: Int) -> [Board]
        where T.SudokuType == SudokuType {
        var solutions: [Board] = []
        _ = guessAndEliminate(transformation: transformation, maxSolutions: maxSolutions, solutions: &solutions)
        return solutions
    }
    
    /// Returns false if we are in an impossible situation.
    private mutating func eliminatePossibilities(basedOnSolvedIndex index: Int) -> Bool {
        // The solved cell can never change during the cascade below: eliminations only
        // remove possibilities, and removing the last one fails the whole branch. So
        // the value can be read once up front.
        let valueToRemove = board.cell(at: index)
        assert(valueToRemove.isSolved)
        for indexToRemoveFrom in SudokuType.constants.indicesAffectedByIndex(index) {
            guard removeAndApplyConstraints(valueToRemove: valueToRemove, indexToRemoveFrom: Int(indexToRemoveFrom)) else {
                return false
            }
        }
        return true
    }

    private mutating func removeAndApplyConstraints(valueToRemove: Cell, indexToRemoveFrom: Int) -> Bool {
        var cell = board.cell(at: indexToRemoveFrom)
        guard let didRemove = cell.removeIfPossible(valueToRemove) else { return false }
        if didRemove {
            board.setCell(at: indexToRemoveFrom, to: cell)
            markDirty(indexToRemoveFrom)
            switch cell.count {
            case 1: return eliminatePossibilities(basedOnSolvedIndex: indexToRemoveFrom)
            case 2: return eliminateNakedPairs(basedOnChangeOf: indexToRemoveFrom)
            default: break
            }
        }
        return true
    }
    
    private mutating func unsolvedIndexWithMostConstraints() -> Board.Index? {
        // Collect all cells tied for the fewest possibilities and pick one uniformly
        // with a single RNG draw, instead of reservoir sampling with one draw per tie.
        withUnsafeTemporaryAllocation(of: Board.Index.self, capacity: SudokuType.cells) { tied in
            var bestCount = Int.max
            var tiedCount = 0

            for index in board.indices {
                let count = board.cell(at: index).count
                guard count > 1 else { continue }

                if count < bestCount {
                    bestCount = count
                    tied[0] = index
                    tiedCount = 1
                } else if count == bestCount {
                    tied[tiedCount] = index
                    tiedCount += 1
                }
            }

            guard tiedCount > 1 else { return tiedCount == 1 ? tied[0] : nil }
            return tied[Int.random(in: 0..<tiedCount, using: &rng)]
        }
    }
    
    private mutating func guessAndEliminate<T: SudokuCellTransformation>(
        transformation: T.Type,
        maxSolutions: Int,
        solutions: inout [Board]
    ) -> Bool where T.SudokuType == SudokuType {
        guard let index = self.unsolvedIndexWithMostConstraints() else {
            solutions.append(self.board)
            return true
        }
        var remainingGuesses = board.cell(at: index)
        while let guess = T.next(from: &remainingGuesses, rng: &rng) {
            var newSolver = self
            newSolver.board.setCell(at: index, to: guess)
            newSolver.markDirty(index)
            if newSolver.eliminatePossibilities(basedOnSolvedIndex: index)
                && newSolver.runDeductionSweeps()
                && newSolver.guessAndEliminate(
                    transformation: transformation,
                    maxSolutions: maxSolutions,
                    solutions: &solutions) {
                self.rng = newSolver.rng
                if solutions.count >= maxSolutions { return true }
            } else {
                self.rng = newSolver.rng
                guard removeAndApplyConstraints(valueToRemove: guess, indexToRemoveFrom: index) else { return false }
            }
        }
        return true
    }
    
    /// Runs the deduction sweeps over the units that changed since the last sweep.
    /// The dirty masks are snapshotted and cleared up front; eliminations made during
    /// these sweeps re-mark their units, which the next guess's sweeps pick up.
    private mutating func runDeductionSweeps() -> Bool {
        let rows = dirtyRows
        let columns = dirtyColumns
        let boxes = dirtyBoxes
        dirtyRows = 0
        dirtyColumns = 0
        dirtyBoxes = 0
        guard findAllHiddenSingles(dirtyRows: rows, dirtyColumns: columns, dirtyBoxes: boxes) else { return false }
        guard findAllLockedCandidates(dirtyBoxes: boxes) else { return false }
        return findAllClaimedCandidates(dirtyRows: rows, dirtyColumns: columns)
    }

    private mutating func findAllHiddenSingles(dirtyRows: UInt32, dirtyColumns: UInt32, dirtyBoxes: UInt32) -> Bool {
        var rows = dirtyRows
        while rows != 0 {
            guard _findHiddenSingles(for: SudokuType.constants.allIndicesInRow(rows.trailingZeroBitCount)) else {
                return false
            }
            rows &= rows &- 1
        }
        var columns = dirtyColumns
        while columns != 0 {
            guard _findHiddenSingles(for: SudokuType.constants.allIndicesInColumn(columns.trailingZeroBitCount)) else {
                return false
            }
            columns &= columns &- 1
        }
        var boxes = dirtyBoxes
        while boxes != 0 {
            guard _findHiddenSingles(for: SudokuType.constants.allIndicesInBox(boxes.trailingZeroBitCount)) else {
                return false
            }
            boxes &= boxes &- 1
        }
        return true
    }

    private mutating func _findHiddenSingles(for indices: UnsafeBufferPointer<UInt16>) -> Bool {
        // One pass over the unit, accumulating which values have been seen at least
        // once, seen more than once, and seen in an already solved cell. A value that
        // has exactly one possible cell, and is not already solved there, is a hidden single.
        var seenOnce: SudokuType.CellStorage = 0
        var seenTwice: SudokuType.CellStorage = 0
        var solved: SudokuType.CellStorage = 0
        for index in indices {
            let cell = board.cell(at: Int(index))
            seenTwice |= seenOnce & cell.storage
            seenOnce |= cell.storage
            if cell.isSolved { solved |= cell.storage }
        }

        // If we cannot find a cell value at all in a unit, then this Sudoku is unsolvable
        guard seenOnce == SudokuType.allTrueCellStorage else { return false }

        var singles = seenOnce & ~seenTwice & ~solved
        while singles != 0 {
            let value = Cell(storage: singles & ~(singles &- 1))
            singles &= singles &- 1
            // Eliminations triggered by a previous hidden single can have changed the
            // unit, so re-find the cell and re-check that the value is still placeable.
            var found = false
            for index in indices where board.cell(at: Int(index)).contains(value) {
                found = true
                if !board.cell(at: Int(index)).isSolved {
                    board.setCell(at: Int(index), to: value)
                    markDirty(Int(index))
                    guard eliminatePossibilities(basedOnSolvedIndex: Int(index)) else { return false }
                }
                break
            }
            guard found else { return false }
        }
        return true
    }
    
    /// Locked candidates ("pointing"): if every cell in a box that can still hold a
    /// value lies in a single row (or column) of that box, then in any solution the
    /// value must be placed inside the box's segment of that row (column), so it can
    /// be eliminated from the rest of the row (column).
    /// Returns false if the board turns out to be unsolvable.
    private mutating func findAllLockedCandidates(dirtyBoxes: UInt32) -> Bool {
        let side = SudokuType.sideOfBox
        // masks[0..<side] accumulate candidates of unsolved cells per box-row,
        // masks[side..<2*side] per box-column.
        return withUnsafeTemporaryAllocation(of: SudokuType.CellStorage.self, capacity: 2 * side) { masks in
            var boxes = dirtyBoxes
            while boxes != 0 {
                let box = boxes.trailingZeroBitCount
                boxes &= boxes &- 1
                for i in 0..<2 * side { masks[i] = 0 }
                let boxIndices = SudokuType.constants.allIndicesInBox(box)
                for offset in 0..<SudokuType.possibilities {
                    let cell = board.cell(at: Int(boxIndices[offset]))
                    guard !cell.isSolved else { continue }
                    masks[offset / side] |= cell.storage
                    masks[side + offset % side] |= cell.storage
                }
                for i in 0..<side {
                    var otherRows: SudokuType.CellStorage = 0
                    var otherColumns: SudokuType.CellStorage = 0
                    for j in 0..<side where j != i {
                        otherRows |= masks[j]
                        otherColumns |= masks[side + j]
                    }
                    let row = (box / side) * side + i
                    guard _eliminateLockedCandidates(
                        values: masks[i] & ~otherRows,
                        for: SudokuType.constants.allIndicesInRow(row),
                        exceptSegment: box % side) else { return false }
                    let column = (box % side) * side + i
                    guard _eliminateLockedCandidates(
                        values: masks[side + i] & ~otherColumns,
                        for: SudokuType.constants.allIndicesInColumn(column),
                        exceptSegment: box / side) else { return false }
                }
            }
            return true
        }
    }

    /// Locked candidates ("claiming"): if every cell in a row (or column) that can
    /// still hold a value lies within a single box, the value must be placed in that
    /// box's segment of the line, so it can be eliminated from the box's other cells.
    /// Returns false if the board turns out to be unsolvable.
    private mutating func findAllClaimedCandidates(dirtyRows: UInt32, dirtyColumns: UInt32) -> Bool {
        // Statically known per Sudoku type, so specialization folds this branch away.
        guard SudokuType.usesClaimedCandidates else { return true }
        let side = SudokuType.sideOfBox
        return withUnsafeTemporaryAllocation(of: SudokuType.CellStorage.self, capacity: side) { segments in
            // Rows: a value confined to one box segment of the row is eliminated
            // from that box's cells outside the row.
            var rows = dirtyRows
            while rows != 0 {
                let line = rows.trailingZeroBitCount
                rows &= rows &- 1
                let indices = SudokuType.constants.allIndicesInRow(line)
                for j in 0..<side { segments[j] = 0 }
                for offset in 0..<SudokuType.possibilities {
                    let cell = board.cell(at: Int(indices[offset]))
                    if !cell.isSolved { segments[offset / side] |= cell.storage }
                }
                for j in 0..<side {
                    var others: SudokuType.CellStorage = 0
                    for k in 0..<side where k != j { others |= segments[k] }
                    guard _eliminateLockedCandidates(
                        values: segments[j] & ~others,
                        for: SudokuType.constants.allIndicesInBox((line / side) * side + j),
                        exceptSegment: line % side) else { return false }
                }
            }
            // Columns: same, but the spared line runs strided through the box.
            var columns = dirtyColumns
            while columns != 0 {
                let line = columns.trailingZeroBitCount
                columns &= columns &- 1
                let indices = SudokuType.constants.allIndicesInColumn(line)
                for j in 0..<side { segments[j] = 0 }
                for offset in 0..<SudokuType.possibilities {
                    let cell = board.cell(at: Int(indices[offset]))
                    if !cell.isSolved { segments[offset / side] |= cell.storage }
                }
                for j in 0..<side {
                    var others: SudokuType.CellStorage = 0
                    for k in 0..<side where k != j { others |= segments[k] }
                    guard _eliminateLockedCandidatesStrided(
                        values: segments[j] & ~others,
                        for: SudokuType.constants.allIndicesInBox(j * side + line / side),
                        exceptSegment: line % side) else { return false }
                }
            }
            return true
        }
    }

    /// Like `_eliminateLockedCandidates`, but the spared segment is strided through
    /// the indices (`offset % side == segment`) — a column's cells within a box —
    /// instead of contiguous.
    private mutating func _eliminateLockedCandidatesStrided(
        values: SudokuType.CellStorage,
        for indices: UnsafeBufferPointer<UInt16>,
        exceptSegment segment: Int
    ) -> Bool {
        var values = values
        let side = SudokuType.sideOfBox
        while values != 0 {
            let value = Cell(storage: values & ~(values &- 1))
            values &= values &- 1
            for offset in 0..<SudokuType.possibilities where offset % side != segment {
                guard removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: Int(indices[offset])) else {
                    return false
                }
            }
        }
        return true
    }

    private mutating func _eliminateLockedCandidates(
        values: SudokuType.CellStorage,
        for indices: UnsafeBufferPointer<UInt16>,
        exceptSegment segment: Int
    ) -> Bool {
        var values = values
        let side = SudokuType.sideOfBox
        while values != 0 {
            let value = Cell(storage: values & ~(values &- 1))
            values &= values &- 1
            for offset in 0..<SudokuType.possibilities where offset / side != segment {
                guard removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: Int(indices[offset])) else {
                    return false
                }
            }
        }
        return true
    }

    private mutating func eliminateNakedPairs(basedOnChangeOf index: Int) -> Bool {
        let value = board.cell(at: index)
        guard _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameRowExclusive(index)) else {
            return false
        }
        guard _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameColumnExclusive(index)) else {
            return false
        }
        return _eliminateNakedPairs(value: value, for: SudokuType.constants.indicesInSameBoxExclusive(index))
    }

    private mutating func _eliminateNakedPairs(value: Cell, for indices: UnsafeBufferPointer<UInt16>) -> Bool {
        assert(value.count == 2)
        var cellWithSameTwoValues: Int?
        for index in indices where board.cell(at: Int(index)) == value {
            cellWithSameTwoValues = Int(index)
            break
        }
        guard let cellWithSameTwoValues else { return true }
        // Found a duplicate. Loop over all indices, except the current one and remove from that
        for indexToRemoveFrom in indices where Int(indexToRemoveFrom) != cellWithSameTwoValues {
            // If more than two cells only have the same two possibilities, this is unsolvable
            guard value != board.cell(at: Int(indexToRemoveFrom)) else { return false }
            guard removeAndApplyConstraints(valueToRemove: value, indexToRemoveFrom: Int(indexToRemoveFrom)) else {
                return false
            }
        }
        return true
    }
    
}
