struct SudokuBoardSIMD3x32 {
    
    typealias Storage = SIMD32<UInt16>
    typealias Mask = SIMDMask<SIMD32<UInt16.SIMDMaskScalar>>
    
    /// Stores 3 rows (27 cells) per element. The last 5 lanes per simd vector are padding.
    private(set) var storage: (Storage, Storage, Storage)
    
    static let empty: SudokuBoardSIMD3x32 = SudokuBoardSIMD3x32(empty: ())
    
    private init(empty: ()) {
        let allPossibilities = Storage(repeating: .allPossibilities)
        self.storage = (allPossibilities, allPossibilities, allPossibilities)
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
    
    init(storage: (Storage, Storage, Storage)) {
        self.storage = storage
    }
    
    private static let allSet = Storage(
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9)

    var isSolved: Bool {
        return self.storage.0.nonzeroBitCount == Self.allSet
            && self.storage.1.nonzeroBitCount == Self.allSet
            && self.storage.2.nonzeroBitCount == Self.allSet
    }
    
}

extension SudokuBoardSIMD3x32: Equatable {
    
    static func == (lhs: SudokuBoardSIMD3x32, rhs: SudokuBoardSIMD3x32) -> Bool {
        lhs.storage == rhs.storage
    }
    
}

extension SudokuBoardSIMD3x32: Collection, MutableCollection {

    var startIndex: Int { 0 }
    var endIndex: Int { 81 }
    func index(after i: Int) -> Int { i + 1 }
    
    subscript(i: Int) -> UInt16 {
        //TODO: Do we need the inlining?
        @inline(__always) get {
            assert((0..<81).contains(i))
            let (storageIndex, cellIndex) = i.quotientAndRemainder(dividingBy: 27)
            switch storageIndex {
            case 0: return self.storage.0[cellIndex]
            case 1: return self.storage.1[cellIndex]
            case 2: return self.storage.2[cellIndex]
            default: fatalError()
            }
        }
        @inline(__always) set {
            assert((0..<81).contains(i))
            let (storageIndex, cellIndex) = i.quotientAndRemainder(dividingBy: 27)
            switch storageIndex {
            case 0: self.storage.0[cellIndex] = newValue
            case 1: self.storage.1[cellIndex] = newValue
            case 2: self.storage.2[cellIndex] = newValue
            default: fatalError()
            }
        }
    }
    
}

extension SudokuBoardSIMD3x32 {
    
    enum Error: Swift.Error {
        case unsolvable
    }
    
}

extension SudokuBoardSIMD3x32 {
    
    mutating func solveConstraints() throws {
        var last = self
        while true {
            try self.solveConstraintsOneRound()
            if self.isSolved || self == last { return }
            last = self
        }
    }
    
    mutating func solveConstraintsOneRound() throws {
        
        //TODO: Consider if we can speed this up by running s0, s1 and s2-operations in paralell for rows and boxes.
        // Not possible for columns though, because we need to look at two vectors at a time.
        
        var (s0, s1, s2) = self.storage
        
        // Rows
        try solveConstraints(update: &s0, masks: Self.rowMasks, indicies: Self.rowIndicies)
        try solveConstraints(update: &s1, masks: Self.rowMasks, indicies: Self.rowIndicies)
        try solveConstraints(update: &s2, masks: Self.rowMasks, indicies: Self.rowIndicies)

        // Boxes
        try solveConstraints(update: &s0, masks: Self.boxMasks, indicies: Self.boxIndicies)
        try solveConstraints(update: &s1, masks: Self.boxMasks, indicies: Self.boxIndicies)
        try solveConstraints(update: &s2, masks: Self.boxMasks, indicies: Self.boxIndicies)
        
        // Columns
        try solveConstraintsForeignColumns(update: &s0, updateMasks: Self.colMasks, basedOn: s1, basedOnIndicies: Self.colIndicies)
        try solveConstraintsForeignColumns(update: &s0, updateMasks: Self.colMasks, basedOn: s2, basedOnIndicies: Self.colIndicies)
        try solveConstraintsForeignColumns(update: &s1, updateMasks: Self.colMasks, basedOn: s0, basedOnIndicies: Self.colIndicies)
        try solveConstraintsForeignColumns(update: &s1, updateMasks: Self.colMasks, basedOn: s2, basedOnIndicies: Self.colIndicies)
        try solveConstraintsForeignColumns(update: &s2, updateMasks: Self.colMasks, basedOn: s0, basedOnIndicies: Self.colIndicies)
        try solveConstraintsForeignColumns(update: &s2, updateMasks: Self.colMasks, basedOn: s1, basedOnIndicies: Self.colIndicies)
        
        self.storage = (s0, s1, s2)
        
    }
    
    private mutating func solveConstraints(update: inout Storage, masks: [Mask], indicies: [[Int]]) throws {
        
        let isSolvedMask = update.nonzeroBitCount .== 1
        
        for number in indicies.indices {
            
            var accumulatedDeletion: UInt16 = UInt16.allPossibilities
            var solvedValuesFound: UInt16 = .zero
            
            for i in indicies[number] where isSolvedMask[i] {
                
                let solvedValue = update[i]
                
                // We have identified a solved value. Check if this value has already been found before, in which case we are in an invalid state
                guard (solvedValue & solvedValuesFound) == .zero else { throw Error.unsolvable }
                
                // Register this solved value
                solvedValuesFound |= solvedValue
                
                accumulatedDeletion &= ~solvedValue
                
            }
            
            // Create the deletion vector and remove from update
            var deletionVector = Storage.max
            deletionVector.replace(with: accumulatedDeletion, where: .!(isSolvedMask .| masks[number]))
            update &= deletionVector
            
        }
    }
    
    // TODO: Consider if we can merge the two solveConstrains methods or have one forward to the other
    private mutating func solveConstraintsForeignColumns(update: inout Storage, updateMasks: [Mask], basedOn: Storage, basedOnIndicies: [[Int]]) throws {
        
        let isSolvedMask = basedOn.nonzeroBitCount .== 1
        
        for number in basedOnIndicies.indices {
            
            var accumulatedDeletion: UInt16 = UInt16.allPossibilities
            var solvedValuesFound: UInt16 = .zero
            
            for i in basedOnIndicies[number] where isSolvedMask[i] {
                
                let solvedValue = basedOn[i]
                
                // We have identified a solved value. Check if this value has already been found before, in which case we are in an invalid state
                guard (solvedValue & solvedValuesFound) == .zero else { throw Error.unsolvable }
                
                // Register this solved value
                solvedValuesFound |= solvedValue
                
                accumulatedDeletion &= ~solvedValue
            }
            
            // Create the deletion vector and remove from update
            var deletionVector = Storage.max
            deletionVector.replace(with: accumulatedDeletion, where: .!updateMasks[number])
            update &= deletionVector
            
        }
    }
    
    //TODO: Consider using a fixedArray81<UInt8> (or even fewer, given the minimum clues) for the indicies and an offset for the first non-solved Index
    func removedSolvedAndSort(indicies: inout [Int]) {
        let nonZeroCountBoard = Self(storage: (self.storage.0.nonzeroBitCount, self.storage.1.nonzeroBitCount, self.storage.2.nonzeroBitCount))
        indicies.removeAll { nonZeroCountBoard[$0] == 1 }
        indicies.sort { nonZeroCountBoard[$0] < nonZeroCountBoard[$1] }
    }
    
    mutating func backtrack(unsolvedIndicies: [Int]) throws -> SudokuBoardSIMD3x32 {
        guard let index = unsolvedIndicies.first else { return self }
        for guess in self[index] {
            do {
                var newBoard = self
                newBoard[index] = guess
                try newBoard.solveConstraints()
                var unsolvedIndicies = unsolvedIndicies
                self.removedSolvedAndSort(indicies: &unsolvedIndicies)
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
    
    func findFirstSolution() throws -> SudokuBoardSIMD3x32 {
        var newBoard = self
        try newBoard.solveConstraints()
        var unsolvedIndicies = Array(0..<81)
        //TODO:Remove
        self.removedSolvedAndSort(indicies: &unsolvedIndicies)
        return try newBoard.backtrack(unsolvedIndicies: unsolvedIndicies)
    }
    
}

extension SudokuBoardSIMD3x32: CustomStringConvertible {
    
    var description: String {
        map { $0.solvedValueAsNumber.flatMap(String.init) ?? "." }.joined()
    }
}
