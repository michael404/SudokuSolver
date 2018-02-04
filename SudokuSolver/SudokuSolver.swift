public extension SudokuBoard {
    
    enum SolvingMethod {
        case fromStart
        case fromRowWithMostFilledValues
    }

    func findFirstSolution(method: SolvingMethod = .fromRowWithMostFilledValues) throws -> SudokuBoard {
        guard isValid else { throw SudokuSolverError.unsolvable }
        guard !isFullyFilled else { throw SudokuSolverError.boardAlreadyFilled }
        guard let solution = try _solutions(method: method).first else {
            throw SudokuSolverError.unsolvable
        }
        return solution
    }
    
    func findAllSolutions(maxSolutions: Int = 1000) throws -> [SudokuBoard] {
        guard isValid else { throw SudokuSolverError.unsolvable }
        guard !isFullyFilled else { throw SudokuSolverError.boardAlreadyFilled }
        precondition(maxSolutions >= 1, "maxSolutions must be 1 or above")
        return try _solutions(mode: .findAll(maxSolutions: maxSolutions))
    }
}

internal extension SudokuBoard {
    
    enum FindMode {
        case findFirst
        case findAll(maxSolutions: Int)
    }
    
    func _solutions(mode: FindMode = .findFirst, method: SolvingMethod = .fromStart, randomizedCellValues: Bool = false) throws -> [SudokuBoard] {
        
        var allSolutions: [SudokuBoard] = []
        var board = self
        var validator = SudokuValidator(board)
        var cellValues = Array(1...9)
        
        let coordinateIterator: Array<SudokuCoordinate>.Iterator
        switch method {
        case .fromStart:
            coordinateIterator = board.indices.filter({ board[$0] == nil }).map(SudokuCoordinate.init).makeIterator()
        case .fromRowWithMostFilledValues:
            coordinateIterator = coordinatesSortedByRowWithMostFilledValues().makeIterator()
        }
        
        // Returns true once the function is done, depending on the parameters passed to the function
        func _solve(_ coordinateIterator: Array<SudokuCoordinate>.Iterator) throws -> Bool {
            var coordinateIterator = coordinateIterator
            
            // If we are at the end of the indicies, we need to take different
            // actions, based on the parameters passed to the function
            guard let coordinate = coordinateIterator.next() else {
                allSolutions.append(board)
                switch mode {
                case .findFirst:
                    return true
                case .findAll(let maxSolutions) where allSolutions.count > maxSolutions:
                    throw SudokuSolverError.tooManySolutions
                case .findAll:
                    return false
                }
            }
            
            if randomizedCellValues { cellValues.shuffle() }
            
            // Test out all cellValues, and recurse
            for cellValue in cellValues {
                if validator.validate(cellValue, at: coordinate) {
                    board[coordinate.index] = SudokuCell(unchecked: cellValue)
                    validator.set(cellValue, to: true, at: coordinate)
                    if try _solve(coordinateIterator) {
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
        
        _ = try _solve(coordinateIterator)
        return allSolutions
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
