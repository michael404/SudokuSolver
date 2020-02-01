protocol SudokuCellTransformationGeneric {
    associatedtype SudokuType: SudokuTypeProtocol
    associatedtype CellSequence: Sequence where CellSequence.Element == SudokuType.Cell
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> CellSequence
}

enum NormalGeneric<SudokuType: SudokuTypeProtocol>: SudokuCellTransformationGeneric {
    
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> SudokuType.Cell {
        possibleCellValues
    }
}

enum ShuffleGeneric<SudokuType: SudokuTypeProtocol>: SudokuCellTransformationGeneric {
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> [SudokuType.Cell] {
        var result = Array(possibleCellValues)
        result.shuffle(using: &rng)
        return result
    }
}

enum ReverseGeneric<SudokuType: SudokuTypeProtocol>: SudokuCellTransformationGeneric {
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> SudokuCellReverseSequence<SudokuType.Cell> {
        possibleCellValues.makeReverseSequence()
    }
}
