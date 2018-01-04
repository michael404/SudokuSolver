struct SudokuCell: Equatable {
    
    let cell: Int
    
    init(_ value: Int) {
        guard case 0...9 = value else {
            fatalError("A SudokuCell can only be initialized with a value between 0 and 9")
        }
        self.cell = value
    }
    
}

extension SudokuCell: ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        self.init(value)
    }
    
}

extension SudokuCell: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self.cell = 0
    }
}

extension SudokuCell: CustomStringConvertible {
    
    var description: String {
        return cell == 0 ? " " : cell.description
    }
    
}
