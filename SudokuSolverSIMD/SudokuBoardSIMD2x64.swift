struct SudokuBoardSIMD2x64: Equatable {
    
    // TODO: Consider changing this to 3 x SIMD32<UInt16> instead to fit 3 rows in each. Or at least change s2 to SIMD32
    typealias Storage = SIMD64<UInt16>
    typealias Mask = SIMDMask<SIMD64<UInt16.SIMDMaskScalar>>
    
    /// Stores the first 54 cells (first 6 rows). Last 10 values are padding.
    private(set) var s1: Storage
    /// Stores the last 27 cells (last 3 rows). Last 37 values are padding.
    private(set) var s2: Storage
    
    static let empty: SudokuBoardSIMD2x64 = SudokuBoardSIMD2x64(empty: ())
    
    private init(empty: ()) {
        self.s1 = .init(repeating: .allPossibilities)
        self.s2 = .init(repeating: .allPossibilities)
    }
    
    init<S: StringProtocol>(_ numbers: S) {
        precondition(numbers.count == 81, "Must pass in 81 SudokuCell elements")
        self = .empty
        for (i, char) in zip(0..<81, numbers) {
            self[i] = UInt16(from: char)!
        }
    }
    
    init(_ board: SudokuBoard) {
        self = .empty
        for (i, cell) in zip(0..<81, board) {
            self[i] = cell.storage >> 1
        }
    }
    
    private static let allSetS1 = Storage(
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9)
    private static let allSetS2 = Storage(
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9,
        9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
        9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9)

    var isSolved: Bool {
        return self.s1.nonzeroBitCount == Self.allSetS1 && self.s2.nonzeroBitCount == Self.allSetS2
    }
    
}

extension SudokuBoardSIMD2x64: Collection, MutableCollection {

    var startIndex: Int { 0 }
    var endIndex: Int { 81 }
    func index(after i: Int) -> Int { i + 1 }
    
    subscript(i: Int) -> UInt16 {
        //TODO: Do we need the inlining?
        @inline(__always) get {
            assert((0..<81).contains(i))
            return i < 54 ? self.s1[i] : self.s2[i - 54]
        }
        @inline(__always) set {
            assert((0..<81).contains(i))
            if i < 54 {
                self.s1[i] = newValue
            } else {
                self.s2[i - 54] = newValue
            }
        }
    }
    
}

extension SudokuBoardSIMD2x64 {
    
    enum Error: Swift.Error {
        case unsolvable
    }
    
}

extension SudokuBoardSIMD2x64 {
    
    mutating func solveConstraints() throws {
        var last = self
        while true {
            try self.solveConstraintsOneRound()
            if self.isSolved || self == last { return }
            last = self
        }
    }
    
    mutating func solveConstraintsOneRound() throws {
        
        //TODO: Consider if we can speed this up by running s1-only operations and s2-only operations in parallel
        
        var (s1, s2) = (self.s1, self.s2)
        
        // Rows
        try solveConstraints(update: &s1, masks: Self.rowMasksS1, indicies: Self.rowIndiciesS1)
        try solveConstraints(update: &s2, masks: Self.rowMasksS2, indicies: Self.rowIndiciesS2)

        // Boxes
        try solveConstraints(update: &s1, masks: Self.boxMasksS1, indicies: Self.boxIndiciesS1)
        try solveConstraints(update: &s2, masks: Self.boxMasksS2, indicies: Self.boxIndiciesS2)
        
        // Columns
        try solveConstraints(update: &s1, masks: Self.colMasksS1, indicies: Self.colIndiciesS1)
        try solveConstraintsForeignColumns(update: &s1, updateMasks: Self.colMasksS1, basedOn: s2, basedOnIndicies: Self.colIndiciesS2)
        try solveConstraintsForeignColumns(update: &s2, updateMasks: Self.colMasksS2, basedOn: s1, basedOnIndicies: Self.colIndiciesS1)
        // No need to update s2 based on s2, as that is already covered by the box check
        
        (self.s1, self.s2) = (s1, s2)
        
    }
    
    private mutating func solveConstraints(update: inout Storage, masks: [Mask], indicies: [[Int]]) throws {
        
        for number in indicies.indices {
            
            let original = update
            let isSolvedMask = update.nonzeroBitCount .== 1
            var solvedValuesFound: UInt16 = .zero
            
            for i in indicies[number] where isSolvedMask[i] {
                
                let solvedValue = original[i]
                
                // We have identified a solved value. Check if this value has already been found before, in which case we are in an invalid state
                guard (solvedValue & solvedValuesFound) == .zero else { throw Error.unsolvable }
                
                // Register this solved value
                solvedValuesFound |= solvedValue
                
                // Delete it from all the other cells in the same row/col/box
                // Precalculating is faster for SIMD64
                update &= Self.inverseRepeated[Int(truncatingIfNeeded: solvedValue)]
            }
            
            // Add back the solved values (which were accidentaly deleted)
            update.replace(with: original, where: isSolvedMask)
            
            // Add back all other rows/boxes/columns
            update.replace(with: original, where: masks[number])
        }
    }
    
    // TODO: Consider if we can merge the two solveConstrains methods or have one forward to the other
    private mutating func solveConstraintsForeignColumns(update: inout Storage, updateMasks: [Mask], basedOn: Storage, basedOnIndicies: [[Int]]) throws {
        
        for number in basedOnIndicies.indices {
            
            let original = update
            let isSolvedMask = basedOn.nonzeroBitCount .== 1
            var solvedValuesFound: UInt16 = .zero
            
            
            for i in basedOnIndicies[number] where isSolvedMask[i] {
                
                let solvedValue = basedOn[i]
                
                // We have identified a solved value. Check if this value has already been found before, in which case we are in an invalid state
                guard (solvedValue & solvedValuesFound) == .zero else { throw Error.unsolvable }
                
                // Register this solved value
                solvedValuesFound |= solvedValue
                
                // Delete it from all the other cells in the same row/col/box
                update &= ~Storage(repeating: solvedValue)
            }
            
            // Add back all other columns
            update.replace(with: original, where: updateMasks[number])
            
        }
    }
    
    func unsolvedIndiciesSorted() -> [Int] {
        var result = (0..<81).filter { !self[$0].isSolved }
        result.sort { a, b in self[a].nonzeroBitCount < self[b].nonzeroBitCount }
        return result
    }
    
    mutating func backtrack(unsolvedIndicies: [Int]) throws -> SudokuBoardSIMD2x64 {
        guard let index = unsolvedIndicies.first else { return self }
        for guess in self[index] {
            do {
                var newBoard = self
                newBoard[index] = guess
                try newBoard.solveConstraints()
                var unsolvedIndicies = unsolvedIndicies
                //TODO: Can we SIMDify this operation, e.g. by precomputing an isSolved-vector?
                unsolvedIndicies.removeAll { newBoard[$0].isSolved }
                return try newBoard.backtrack(unsolvedIndicies: unsolvedIndicies)
            } catch {
                // Ignore the error and move on to testing the next possible value for the current index
                continue
            }
        }
        // Only fail and throw if we have tried all possible values for the current cell and all of those
        // branches failed and throwed.
        throw Error.unsolvable
    }
    
    func findFirstSolution() throws -> SudokuBoardSIMD2x64 {
        var newBoard = self
        try newBoard.solveConstraints()
        return try newBoard.backtrack(unsolvedIndicies: newBoard.unsolvedIndiciesSorted())
    }
    
}
