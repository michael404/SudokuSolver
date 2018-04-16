import Foundation

public enum SudokuSolverError: Error {
    
    case unsolvable
    case tooManySolutions
    
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
            swapAt(currentIndex, index(currentIndex, offsetBy: numericCast(random)))
            formIndex(after: &currentIndex)
        }
    }
    
    public func shuffled() -> Self {
        var copy = self
        copy.shuffle()
        return copy
    }
}

//TODO: Remove this when SE-0197 is implemented, probably in Swift 4.2
extension RangeReplaceableCollection where Self: MutableCollection {
    /// Removes from the collection all elements that satisfy the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the
    ///   sequence as its argument and returns a Boolean value indicating
    ///   whether the element should be removed from the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @_inlineable
    public mutating func removeAll(where predicate: (Element) throws -> Bool) rethrows {
        if var i = try index(where: predicate) {
            var j = index(after: i)
            while j != endIndex {
                if try !predicate(self[j]) {
                    swapAt(i, j)
                    formIndex(after: &i)
                }
                formIndex(after: &j)
            }
            removeSubrange(i...)
        }
    }
}
