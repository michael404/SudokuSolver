public extension SudokuBoard {
    
    static func randomStartingBoardBacktrack() -> SudokuBoard {
        return randomStartingBoardBacktrack(rng: &Random.default)
    }
    
    static func randomStartingBoardBacktrack<R: RNG>(rng: inout R) -> SudokuBoard {
        //TODO: check if it is more effective to not generate a full filled board first
        return randomFullyFilledBoardBacktrack(rng: &rng).randomStartingPositionFromFullyFilledBoardBacktrack(rng: &rng)
    }
    
    static func randomFullyFilledBoardBacktrack() -> SudokuBoard {
        return randomFullyFilledBoardBacktrack(rng: &Random.default)
    }
    
    static func randomFullyFilledBoardBacktrack<R: RNG>(rng: inout R) -> SudokuBoard {
        let board = SudokuBoard()
        guard let filledBoard = try? board.findFirstSolutionBacktrack(randomizedCellValues: true, rng: &rng) else {
            fatalError("Could not construct random board. This should not be possible.")
        }
        return filledBoard
    }
    
}

internal extension SudokuBoard {
    
    func randomStartingPositionFromFullyFilledBoardBacktrack() -> SudokuBoard {
        return randomStartingPositionFromFullyFilledBoardBacktrack(rng: &Random.default)
    }
    
    func randomStartingPositionFromFullyFilledBoardBacktrack<R: RNG>(rng: inout R) -> SudokuBoard {
        var board = self

        for index in board.indices.shuffled(using: &rng) {
            let cellAtIndex = board[index]
            board[index] = nil
            switch board.numberOfSolutionsBacktrack() {
            case .none:
                fatalError("Could not find a valid solution despite starting from a valid board. This should not be possible.")
            case .one:
                // Do nothing
                break
            case .multiple:
                // Too many solutions. Add back last cell set to nil and move on with next index
                board[index] = cellAtIndex
            }
        }
        return board
    }
    
}
