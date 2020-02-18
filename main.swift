generateMinimalSudokusAsync(iterations: 1_000_000, maxClues: 20, type: Sudoku9.self) { board in
    print("--> \(board.description) <-- \(board.clues) clues")
}

generateHardToBruteForceSudokusAsync(iterations: 1_000_000, type: Sudoku16.self) { board, nanoseconds in
    print("--> \(board.description) <-- \(nanoseconds) nanoseconds - \(board.clues) clues")
}
