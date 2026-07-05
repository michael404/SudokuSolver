import Dispatch

func countNanoseconds(for function: () -> Void) -> Int {
    let startTime = DispatchTime.now().uptimeNanoseconds
    function()
    let endTime = DispatchTime.now().uptimeNanoseconds
    return Int(clamping: endTime - startTime)
}

func generateMinimalSudokusAsync<SudokuType: SudokuTypeProtocol>(
    iterations: Int,
    maxClues: Int,
    type: SudokuType.Type,
    handler: @escaping @Sendable (SudokuBoard<SudokuType>) -> Void
) {
    let serialQueue = DispatchQueue(label: "SudokuSolver", qos: .userInitiated)
    DispatchQueue.concurrentPerform(iterations: iterations) { _ in
        let board = SudokuBoard<SudokuType>.randomStartingBoard()
        guard board.clues <= maxClues else { return }
        serialQueue.sync { handler(board) }
    }
}

func generateHardToBruteForceSudokusAsync<SudokuType: SudokuTypeProtocol>(
    iterations: Int,
    maxTimeNanoseconds: Int = 25_000_000,
    type: SudokuType.Type,
    handler: @escaping @Sendable (_ board: SudokuBoard<SudokuType>, _ nanoseconds: Int) -> Void
) {
    let serialQueue = DispatchQueue(label: "SudokuSolver", qos: .userInitiated)
    DispatchQueue.concurrentPerform(iterations: iterations) { _ in
        let board = SudokuBoard<SudokuType>.randomStartingBoard()
        let nanoseconds = countNanoseconds {
            guard board.numberOfSolutions() == .one else {
                fatalError("Not solvable or multiple solutions. This should not happen.")
            }
        }
        guard nanoseconds >= maxTimeNanoseconds else { return }
        serialQueue.sync {
            handler(board, nanoseconds)
        }
    }
}
