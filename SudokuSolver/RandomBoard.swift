extension SudokuBoard {

    static func randomStartingBoard() -> SudokuBoard {
        var rng = WyRand()
        return randomStartingBoard(rng: &rng)
    }

    static func randomStartingBoard<R: RNG>(rng: inout R) -> SudokuBoard {
        randomFullyFilledBoard(using: &rng).minimizingClues(using: &rng)
    }

}

internal extension SudokuBoard {

    /// Returns a copy of this board with every removable clue cleared, visiting
    /// cells in a random order. A clue is only removed when doing so provably keeps
    /// the solution unique, so the result has exactly the same single solution as
    /// this board, its clues are a subset of this board's clues, and no single
    /// remaining clue can be removed without losing uniqueness (1-minimality).
    ///
    /// This board must have exactly one solution when called; a fully filled board
    /// trivially qualifies.
    func minimizingClues<R: RNG>(using rng: inout R) -> SudokuBoard {
        assert({ var checkRng = rng
                 return numberOfSolutions(using: &checkRng) == .one }(),
               "minimizingClues requires a board with exactly one solution")
        var board = self
        for index in board.indices.shuffled(using: &rng) {
            // The board so far has a unique solution, so clearing this cell keeps the
            // solution unique iff no *other* value in this cell admits a solution.
            // Checking that directly is much cheaper than proving uniqueness from
            // scratch, which has to re-derive the known solution and then exhaust
            // the rest of the search space.
            let cellAtIndex = board.cell(at: index)
            var alternatives = SudokuType.allTrueCellStorage & ~cellAtIndex.storage
            for peer in SudokuType.constants.indicesAffectedByIndex(index) {
                let peerCell = board.cell(at: Int(peer))
                if peerCell.isSolved { alternatives &= ~peerCell.storage }
            }
            if alternatives != 0 {
                var testBoard = board
                testBoard[index] = Cell(storage: alternatives)
                guard testBoard.findFirstSolution(using: &rng) == nil else {
                    // Some other value also completes the board, so this clue is
                    // load-bearing. Keep it and move on to the next index.
                    continue
                }
            }
            board[index] = .allTrue
        }
        return board
    }

}
