enum SudokuCell: Int {
    
    case empty = 0
    case s1 = 1
    case s2 = 2
    case s3 = 3
    case s4 = 4
    case s5 = 5
    case s6 = 6
    case s7 = 7
    case s8 = 8
    case s9 = 9
    
}

extension SudokuCell: ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        guard let cell = SudokuCell(rawValue: value) else {
            fatalError("A SudokuCell can only be initialized with a value between 0 and 9")
        }
        self = cell
    }
    
}

extension SudokuCell: CustomStringConvertible {
    
    var description: String {
        switch  self {
        case .empty:
            return " "
        default:
            return String(self.rawValue)
        }
    }
    
}

extension SudokuCell {
    
    static let allNonEmpyValues: [SudokuCell] = [.s1, .s2, .s3, .s4, .s5, .s6, .s7, .s8, .s9]
    
}
