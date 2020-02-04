import Foundation

func countNanoseconds(for function: () -> ()) -> Int {
    let startTime = Date()
    function()
    let endTime = Date()
    return Calendar.current.dateComponents([.nanosecond], from: startTime, to: endTime).nanosecond!
}

func generateMinimalSudokusAsync<SudokuType: SudokuTypeProtocol>(
    iterations: Int,
    maxClues: Int,
    type: SudokuType.Type,
    handler: @escaping (SudokuBoard<SudokuType>) -> ()
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
    handler: @escaping (_ board: SudokuBoard<SudokuType>, _ nanoseconds: Int) -> ()
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
