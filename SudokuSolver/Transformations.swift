protocol SudokuCellTransformation {
    associatedtype CellValueSequence: Sequence where CellValueSequence.Element == SudokuCell
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell, rng: inout R) -> CellValueSequence
}

enum Normal: SudokuCellTransformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell, rng: inout R) -> SudokuCell {
        return possibleCellValues
    }
}

enum Shuffle: SudokuCellTransformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell, rng: inout R) -> [SudokuCell] {
        var result = Array(possibleCellValues)
        result.shuffle(using: &rng)
        return result
    }
}

enum Reverse: SudokuCellTransformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell, rng: inout R) -> SudokuCellReversedIterator {
        return SudokuCellReversedIterator(possibleCellValues)
    }
}
