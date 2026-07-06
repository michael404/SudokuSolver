protocol SudokuCellTransformation {
    associatedtype SudokuType: SudokuTypeProtocol
    /// Pops the next guess out of `remaining`, or returns nil when all guesses are
    /// exhausted. Popping from a bitmask instead of materializing a shuffled Array
    /// keeps the guess loop allocation-free.
    static func next<R: RNG>(
        from remaining: inout SudokuCell<SudokuType>,
        rng: inout R
    ) -> SudokuCell<SudokuType>?
}

enum Normal<SudokuType: SudokuTypeProtocol>: SudokuCellTransformation {

    static func next<R: RNG>(
        from remaining: inout SudokuCell<SudokuType>,
        rng: inout R
    ) -> SudokuCell<SudokuType>? {
        guard remaining.storage != 0 else { return nil }
        let lowestBitSet = remaining.storage & ~(remaining.storage &- 1)
        remaining.storage ^= lowestBitSet
        return SudokuCell(storage: lowestBitSet)
    }
}

enum Shuffle<SudokuType: SudokuTypeProtocol>: SudokuCellTransformation {

    static func next<R: RNG>(
        from remaining: inout SudokuCell<SudokuType>,
        rng: inout R
    ) -> SudokuCell<SudokuType>? {
        let count = remaining.storage.nonzeroBitCount
        guard count != 0 else { return nil }
        // Popping a uniformly random remaining bit each time yields a uniformly
        // random guess order, without materializing and shuffling an Array.
        var skip = count == 1 ? 0 : Int.random(in: 0..<count, using: &rng)
        var candidates = remaining.storage
        while skip > 0 {
            candidates &= candidates &- 1
            skip -= 1
        }
        let chosenBit = candidates & ~(candidates &- 1)
        remaining.storage ^= chosenBit
        return SudokuCell(storage: chosenBit)
    }
}
