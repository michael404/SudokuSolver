extension SudokuBoard {
    
    static func randomStartingBoard() -> SudokuBoard {
        var rng = Xoroshiro()
        return randomStartingBoard(rng: &rng)
    }
    
    static func randomStartingBoard<R: RNG>(rng: inout R) -> SudokuBoard {
        //TODO: check if it is more effective to not generate a full filled board first
        randomFullyFilledBoard(rng: &rng).randomStartingPositionFromFullyFilledBoard(rng: &rng)
    }


}

internal extension SudokuBoard {
    
    func randomStartingPositionFromFullyFilledBoard() -> SudokuBoard {
        var rng = Xoroshiro()
        return randomStartingPositionFromFullyFilledBoard(rng: &rng)
    }
    
    func randomStartingPositionFromFullyFilledBoard<R: RNG>(rng: inout R) -> SudokuBoard {
        var board = self
        for index in board.indices.shuffled(using: &rng) {
            let cellAtIndex = board[index]
            board[index] = .allTrue
            switch board.numberOfSolutions(using: rng) {
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
        assert(board.numberOfSolutions(using: rng) == .one)
        return board
    }
    
}

