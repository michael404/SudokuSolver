public struct SudokuCell: Hashable {
    
    internal let value: Int
    
    init(_ value: Int) {
        guard case 0...9 = value else {
            fatalError("A SudokuCell can only be initialized with a value between 0 and 9")
        }
        self.value = value
    }
    
    internal init(unchecked value: Int) {
        self.value = value
    }
    
}

extension SudokuCell: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(unchecked: value)
    }
}

extension SudokuCell: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.value = 0
    }
}

extension SudokuCell: CustomStringConvertible {
    public var description: String {
        return value == 0 ? " " : value.description
    }
}
