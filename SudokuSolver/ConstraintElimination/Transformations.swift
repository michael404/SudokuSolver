protocol PossibleCellValuesTransformation {
    associatedtype CellValueSequence: Sequence where CellValueSequence.Element == PossibleCellValues
    static func transform<R: RNG>(_ possibleCellValues: PossibleCellValues, rng: inout R) -> CellValueSequence
}

enum Normal: PossibleCellValuesTransformation {
    static func transform<R: RNG>(_ possibleCellValues: PossibleCellValues, rng: inout R) -> PossibleCellValues {
        return possibleCellValues
    }
}

enum Shuffle: PossibleCellValuesTransformation {
    static func transform<R: RNG>(_ possibleCellValues: PossibleCellValues, rng: inout R) -> [PossibleCellValues] {
        var result = Array(possibleCellValues)
        result.shuffle(using: &rng)
        return result
    }
}

enum Reverse: PossibleCellValuesTransformation {
    static func transform<R: RNG>(_ possibleCellValues: PossibleCellValues, rng: inout R) -> PossibleCellValuesReversedIterator {
        return PossibleCellValuesReversedIterator(possibleCellValues)
    }
}
