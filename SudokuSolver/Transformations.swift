protocol SudokuCellTransformation {
    associatedtype SudokuType: SudokuTypeProtocol
    associatedtype CellSequence: Sequence where CellSequence.Element == SudokuType.Cell
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> CellSequence
}

enum Normal<SudokuType: SudokuTypeProtocol>: SudokuCellTransformation {
    
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> SudokuType.Cell {
        possibleCellValues
    }
}

enum Shuffle<SudokuType: SudokuTypeProtocol>: SudokuCellTransformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> [SudokuType.Cell] {
        var result = Array(possibleCellValues)
        result.shuffle(using: &rng)
        return result
    }
}

enum Reverse<SudokuType: SudokuTypeProtocol>: SudokuCellTransformation {
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> SudokuCellReverseSequence<SudokuType.Cell> {
        possibleCellValues.makeReverseSequence()
    }
}
