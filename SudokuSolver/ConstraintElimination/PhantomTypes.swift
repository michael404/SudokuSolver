protocol PossibleCellValuesTransformation {
    associatedtype CellValueSequence: Sequence where CellValueSequence.Element == PossibleCellValues
    static func transform(_ possibleCellValues: PossibleCellValues) -> CellValueSequence
}

enum NoTransformation: PossibleCellValuesTransformation {
    static func transform(_ possibleCellValues: PossibleCellValues) -> PossibleCellValues {
        return possibleCellValues
    }
}

enum Shuffle: PossibleCellValuesTransformation {
    static func transform(_ possibleCellValues: PossibleCellValues) -> [PossibleCellValues] {
        return possibleCellValues.shuffled()
    }
}

enum Reverse: PossibleCellValuesTransformation {
    static func transform(_ possibleCellValues: PossibleCellValues) -> PossibleCellValuesReversedIterator {
        return PossibleCellValuesReversedIterator(possibleCellValues)
    }
}
