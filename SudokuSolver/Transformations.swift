protocol SudokuCellTransformationGeneric {
    associatedtype SudokuType: SudokuTypeProtocol
    associatedtype CellSequence: Sequence where CellSequence.Element == SudokuType.Cell
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> CellSequence
}

enum NormalGeneric<SudokuType: SudokuTypeProtocol>: SudokuCellTransformationGeneric {
    
    @_specialize(where SudokuType == Sudoku9, R == Xoroshiro)
    @_specialize(where SudokuType == Sudoku16, R == Xoroshiro)
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

#warning("can we get a reversedcollection here?")
enum ReverseGeneric<SudokuType: SudokuTypeProtocol>: SudokuCellTransformationGeneric {
//    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> ReversedCollection<SudokuType.Cell> {
    static func transform<R: RNG>(_ possibleCellValues: SudokuType.Cell, rng: inout R) -> [SudokuType.Cell] {
        possibleCellValues.reversed()
    }
}
