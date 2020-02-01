#warning("restore bidirectional")
protocol SudokuCellProtocol: Hashable, CustomStringConvertible, CustomDebugStringConvertible, Collection where Element == Self {
    init(solved: Int)
    init(character: Character)
    var isSolved: Bool { get }
    var count: Int { get }
    func contains(_ value: Self) -> Bool
    mutating func remove(_ value: Self) throws -> Bool
    static var allTrue: Self { get }
}

//TODO: Consider if we can implement some of the methods in an extention here
