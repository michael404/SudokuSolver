public extension SudokuBoard {
    
    static func randomStartingBoardCE() -> SudokuBoard {
        return randomStartingBoardCE(rng: &Random.default)
    }
    
    static func randomStartingBoardCE<R: RNG>(rng: inout R) -> SudokuBoard {
        //TODO: check if it is more effective to not generate a full filled board first
        return randomFullyFilledBoardCE(rng: &rng).randomStartingPositionFromFullyFilledBoardCE(rng: &rng)
    }


}

internal extension SudokuBoard {
    
    func randomStartingPositionFromFullyFilledBoardCE() -> SudokuBoard {
        return randomStartingPositionFromFullyFilledBoardCE(rng: &Random.default)
    }
    
    func randomStartingPositionFromFullyFilledBoardCE<R: RNG>(rng: inout R) -> SudokuBoard {
        var board = self
        
        for index in board.indices.shuffled(using: &rng) {
            let cellAtIndex = board[index]
            board[index] = nil
            switch board.numberOfSolutionsCE() {
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

