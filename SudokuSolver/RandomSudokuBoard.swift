public extension SudokuBoard {
    
    static func randomStartingBoard() -> SudokuBoard {
        //TODO: check if it is more effective to not generate a full filled board first
        return randomFullyFilledBoard().randomStartingPositionFromFullyFilledBoard()
    }
    
    static func randomFullyFilledBoard() -> SudokuBoard {
        let board = SudokuBoard()
        guard let filledBoards = try? board._solutions(randomizedCellValues: true), let filledBoard = filledBoards.first else {
            fatalError("Could not construct random board. This should not be possible.")
        }
        return filledBoard
    }
    
}

internal extension SudokuBoard {
    
    //TODO: Can we remove the first 41 (?) cells without any checks?
    // Maximum minimal board should be 40 cells according to wikipedia
    func randomStartingPositionFromFullyFilledBoard() -> SudokuBoard {
        var board = self
        let shuffledIndicies = board.indices.shuffled()
        for index in shuffledIndicies {
            let cellAtIndex = board[index]
            board[index] = nil
            do {
                guard try board._solutions(mode: .findAll(maxSolutions: 1)).count == 1 else {
                    // no valid solution - this should not happen
                    fatalError("Could not find a valid solution despite starting from a valid board. This should not be possible.")
                }
            } catch {
                // too many solutions - reset last removal
                // and move on
                board[index] = cellAtIndex
            }
        }
        return board
    }
    
}
