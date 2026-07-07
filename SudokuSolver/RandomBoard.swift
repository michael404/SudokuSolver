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
    /// this board and its clues are a subset of this board's clues.
    ///
    /// With the default unlimited `nodeLimit` the result is also 1-minimal: no
    /// single remaining clue can be removed without losing uniqueness. A finite
    /// `nodeLimit` bounds each removal check and conservatively keeps any clue
    /// whose check runs out of budget, which keeps large-board minimization from
    /// searching indefinitely at the cost of possibly retaining removable clues.
    ///
    /// This board must have exactly one solution when called; a fully filled board
    /// trivially qualifies.
    func minimizingClues<R: RNG>(using rng: inout R, nodeLimit: Int = .max) -> SudokuBoard {
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
                // Keep the clue unless the check proves no alternative solution
                // exists; an indeterminate, budget-limited check keeps it too.
                guard testBoard.findFirstSolution(using: &rng, nodeLimit: nodeLimit) == .unsolvable else {
                    continue
                }
            }
            board[index] = .allTrue
        }
        return board
    }

}
