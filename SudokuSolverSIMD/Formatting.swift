extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension SudokuBoardSIMD2x64: CustomStringConvertible {
    
    var description: String {
        map { $0.solvedValue.flatMap(String.init) ?? "." }.joined()
    }
}

extension SudokuBoardSIMD2x64: CustomDebugStringConvertible {
    
    var debugDescription: String {
        self
            .map { $0.sudokuDescription }
            .chunked(into: 9)
            .map { $0.joined(separator: " ") }
            .joined(separator: "\n")
    }
    
}
