protocol SudokuCellTransformation {
    associatedtype SudokuType: SudokuTypeProtocol
    associatedtype CellSequence: Sequence where CellSequence.Element == SudokuCell<SudokuType>
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell<SudokuType>, rng: inout R) -> CellSequence
}

enum Normal<SudokuType: SudokuTypeProtocol>: SudokuCellTransformation {
    
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell<SudokuType>, rng: inout R) -> SudokuCell<SudokuType> {
        possibleCellValues
    }
}

enum Shuffle<SudokuType: SudokuTypeProtocol>: SudokuCellTransformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell<SudokuType>, rng: inout R) -> [SudokuCell<SudokuType>] {
        var result = Array(possibleCellValues)
        result.shuffle(using: &rng)
        return result
    }
}

enum Reverse<SudokuType: SudokuTypeProtocol>: SudokuCellTransformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuCell<SudokuType>, rng: inout R) -> SudokuCell<SudokuType>.ReverseSequence {
        possibleCellValues.makeReverseSequence()
    }
}
