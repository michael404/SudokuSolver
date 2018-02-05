public extension SudokuBoard {
    
    // TODO: Hack to get around that generic parameters cannot be defaulted (?)
    static func randomStartingBoard() -> SudokuBoard {
        return randomStartingBoard(clues: (17..<81))
    }
    
    // TODO: This is extreamly inefficient when searching for boards with <25 clues
    static func randomStartingBoard<R: RangeExpression>(clues: R) -> SudokuBoard where R.Bound == Int {
        let clues = clues.relative(to: (0..<81))
        precondition(clues.lowerBound >= 17, "Lower bound of clues must be 17 or above")
        precondition(clues.upperBound <= 81, "Upper bound of clues must be under 81")
        
        let solvedBoard = randomFullyFilledBoard()
        var board: SudokuBoard
        repeat {
            board = solvedBoard.randomStartingPositionFromFullyFilledBoard()
        } while !clues.contains(board.clues)
        return board
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
