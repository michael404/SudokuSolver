struct SudokuCell: Equatable {
    
    let cell: Int?
    
    init(_ value: Int) {
        switch value {
        case 0: self = nil
        case 1...9: self.cell = value
        default: fatalError("A SudokuCell can only be initialized with a value between 0 and 9")
        }
    }
    
}

extension SudokuCell: ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        self.init(value)
    }
    
}

extension SudokuCell: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self.cell = nil
    }
}

extension SudokuCell: CustomStringConvertible {
    
    var description: String {
        guard let cell = self.cell else { return " " }
        return cell.description
    }
    
}
