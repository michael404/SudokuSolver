protocol SudokuCell16Transformation {
    associatedtype CellValueSequence: Sequence where CellValueSequence.Element == SudokuCell16
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell16, rng: inout R) -> CellValueSequence
}

enum Normal16: SudokuCell16Transformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell16, rng: inout R) -> SudokuCell16 {
        possibleCellValues
    }
}

enum Shuffle16: SudokuCell16Transformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell16, rng: inout R) -> [SudokuCell16] {
        var result = Array(possibleCellValues)
        result.shuffle(using: &rng)
        return result
    }
}

enum Reverse16: SudokuCell16Transformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell16, rng: inout R) -> ReversedCollection<SudokuCell16> {
        possibleCellValues.reversed()
    }
}
