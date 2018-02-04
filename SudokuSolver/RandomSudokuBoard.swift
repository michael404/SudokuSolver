public extension SudokuBoard {
    
    static func randomStartingBoard() -> SudokuBoard {
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
                // too many solutions - reset last removal and break
                board[index] = cellAtIndex
                break
            }
        }
        return board
    }
    
}
