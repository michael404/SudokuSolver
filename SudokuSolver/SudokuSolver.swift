public extension SudokuBoard {

    //TODO: Once Swift incorporates a RNG protocol, add affordances to use it, and use a PRNG in the unit tests
    func findFirstSolution(randomizedCellValues: Bool = false) throws -> SudokuBoard {
        
        guard isValid else { throw SudokuSolverError.unsolvable }
        
        var board = self
        var validator = SudokuValidator(board)
        var cellValues = Array(1...9)
        
        let coordinateIterator = board.indices.filter({ board[$0] == nil }).map(SudokuCoordinate.init).makeIterator()
        
        // Returns true once the function has found a solution
        func _solve(_ coordinateIterator: Array<SudokuCoordinate>.Iterator) -> Bool {
            var coordinateIterator = coordinateIterator
            
            // If we are at the end of the indicies, we have found a solution
            guard let coordinate = coordinateIterator.next() else {
                return true
            }
            
            if randomizedCellValues { cellValues.shuffle() }
            
            // Test out all cellValues, and recurse
            for cellValue in cellValues {
                if validator.validate(cellValue, at: coordinate) {
                    board[coordinate.index] = SudokuCell(unchecked: cellValue)
                    validator.set(cellValue, to: true, at: coordinate)
                    if _solve(coordinateIterator) {
                        return true
                    } else {
                        validator.set(cellValue, to: false, at: coordinate)
                    }
                }
            }
            // Reset shared state if branch returned false
            board[coordinate.index] = nil
            return false
        }
        
        let foundSolution = _solve(coordinateIterator)
        guard foundSolution else { throw SudokuSolverError.unsolvable }
        return board

    }
    
    func findAllSolutions(maxSolutions: Int = 1000) throws -> [SudokuBoard] {
        
        guard isValid else { throw SudokuSolverError.unsolvable }
        precondition(maxSolutions >= 1, "maxSolutions must be 1 or above")
        
        var allSolutions: [SudokuBoard] = []
        var board = self
        var validator = SudokuValidator(board)
        
        
        let coordinateIterator: Array<SudokuCoordinate>.Iterator = board.indices.filter({ board[$0] == nil }).map(SudokuCoordinate.init).makeIterator()
        
        // Returns true once the function is done, depending on the parameters passed to the function
        func _solve(_ coordinateIterator: Array<SudokuCoordinate>.Iterator) throws {
            var coordinateIterator = coordinateIterator
            
            // If we are at the end of the indicies, append the solution and consider
            // breaking if we are above the maximum number of solutions
            guard let coordinate = coordinateIterator.next() else {
                allSolutions.append(SudokuBoard(board))
                guard allSolutions.count <= maxSolutions else {
                    throw SudokuSolverError.tooManySolutions
                }
                return
            }
            
            // Test out all cellValues, and recurse
            for cellValue in 1...9 {
                if validator.validate(cellValue, at: coordinate) {
                    board[coordinate.index] = SudokuCell(unchecked: cellValue)
                    validator.set(cellValue, to: true, at: coordinate)
                    try _solve(coordinateIterator)
                    validator.set(cellValue, to: false, at: coordinate)
                }
                // Reset shared state and move on
                board[coordinate.index] = nil
            }
        }
        try _solve(coordinateIterator)
        return allSolutions
    }
    
    enum NumberOfSolutions {
        case none
        case one
        case multiple
    }
    
    func numberOfSolutions() -> NumberOfSolutions {
        do {
            let solutions = try findAllSolutions(maxSolutions: 1)
            switch solutions.count {
            case 0: return .none
            case 1: return .one
            default: fatalError("Unexpected count")
            }
        } catch let error as SudokuSolverError {
            switch error {
            case .unsolvable: return .none
            case .tooManySolutions: return .multiple
            }
        } catch {
            fatalError("Unexpected error type")
        }
        
    }
    
    private func coordinatesSortedByRowWithMostFilledValues() -> [SudokuCoordinate] {
        
        var unnfilledCellIndiciesPerRow: [[Int]] = (0...8).map { rowIndex in
            let startIndex = rowIndex * 9
            let endIndex = startIndex + 9
            let unfilledCellIndices = self[startIndex..<endIndex].indices.filter { self[$0] == nil }
            return unfilledCellIndices
        }
        unnfilledCellIndiciesPerRow.sort { $0.count < $1.count }
        return unnfilledCellIndiciesPerRow.flatMap({ $0.map(SudokuCoordinate.init) })
    }
    
}
