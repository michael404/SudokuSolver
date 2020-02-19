extension SudokuBoard {
    
    static func randomStartingBoard() -> SudokuBoard {
        var rng = WyRand()
        return randomStartingBoard(rng: &rng)
    }
    
    static func randomStartingBoard<R: RNG>(rng: inout R) -> SudokuBoard {
        randomFullyFilledBoard(using: rng).randomStartingPositionFromFullyFilledBoard(using: rng)
    }

}

internal extension SudokuBoard {
    
    func randomStartingPositionFromFullyFilledBoard() -> SudokuBoard {
        return randomStartingPositionFromFullyFilledBoard(using: WyRand())
    }
    
    func randomStartingPositionFromFullyFilledBoard<R: RNG>(using rng: R) -> SudokuBoard {
        var board = self
        var rng = rng
        for index in board.indices.shuffled(using: &rng) {
            let cellAtIndex = board[index]
            board[index] = .allTrue
            switch board.numberOfSolutions(using: rng) {
            case .none:
                fatalError("Inconsistent state")
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
