import Foundation

public enum SudokuSolverError: Error {
    
    case unsolvable
    case boardAlreadyFilled
    case tooManySolutions
    
}

internal struct SudokuCoordinate {
    
    let index: Int
    let row: Int
    let column: Int
    let block: Int
    
    init(_ index: Int) {
        self.index = index
        self.row = index / 9
        self.column = index % 9
        self.block = (self.row / 3) * 3 + (self.column / 3)
    }
    
}

// TODO: Remove random methods if stdlib incorporates these

extension RandomAccessCollection {
    func randomElement() -> Element {
        let randomIndexOffset: Int = numericCast(arc4random_uniform(numericCast(distance(from: startIndex, to: endIndex))))
        let randomIndex = self.index(startIndex, offsetBy: randomIndexOffset)
        return self[randomIndex]
    }
}

extension Sequence {
    /// Returns the elements of the sequence, shuffled.
    ///
    /// - Parameter generator: The random number generator to use when shuffling
    ///   the sequence.
    /// - Returns: A shuffled array of this sequence's elements.
    @_inlineable
    public func shuffled() -> [Element] {
        var result = ContiguousArray(self)
        result.shuffle()
        return Array(result)
    }
}

extension MutableCollection {
    /// Shuffles the collection in place.
    public mutating func shuffle() {
        guard count > 1 else { return }
        var amount = count
        var currentIndex = startIndex
        while amount > 1 {
            let random: Int = numericCast(arc4random_uniform(numericCast(amount)))
            amount -= 1
            swapAt(
                currentIndex,
                index(currentIndex, offsetBy: numericCast(random))
            )
            formIndex(after: &currentIndex)
        }
    }
    
    public func shuffled() -> Self {
        var copy = self
        copy.shuffle()
        return copy
    }
}
