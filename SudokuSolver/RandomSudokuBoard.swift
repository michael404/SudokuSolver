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
    
    func randomStartingPositionFromFullyFilledBoard() -> SudokuBoard {
        var board = self
        var shuffledIndiciesIterator = board.indices.shuffled().makeIterator()
        
        // Since the maximum number of clues in a minimal Sudoku is 40
        // (https://en.wikipedia.org/wiki/Mathematics_of_Sudoku#Maximum_number_of_givens)
        // we can safely set the first 41 random cells to nil without any checks
        for _ in 0..<41 {
            board[shuffledIndiciesIterator.next()!] = nil
        }
        
        // Try to set the last 40 indicies to nil, while checking that it is stil valid
        // and only has one solution
        for index in shuffledIndiciesIterator {
            let cellAtIndex = board[index]
            board[index] = nil
            do {
                guard try board._solutions(mode: .findAll(maxSolutions: 1)).count == 1 else {
                    // No valid solution - this should not happen
                    fatalError("Could not find a valid solution despite starting from a valid board. This should not be possible.")
                }
            } catch {
                // Too many solutions. Add back last cell set to nil and move on whith next index
                board[index] = cellAtIndex
            }
        }
        return board
    }
    
}
