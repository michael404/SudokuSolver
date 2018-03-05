import Foundation


func generateMinimalSudokusAsync(iterations: Int, maxClues: Int, handler: @escaping (SudokuBoard) -> ()) {
    let serialQueue = DispatchQueue(label: "se.michaelholmgren.SudokuSolver", qos: .userInitiated)
    DispatchQueue.concurrentPerform(iterations: iterations) { _ in
        let board = SudokuBoard.randomStartingBoard()
        guard board.clues <= maxClues else { return }
        serialQueue.sync { handler(board) }
    }
}

func countNanoseconds(for function: () -> ()) -> Int {
    let startTime = Date()
    function()
    let endTime = Date()
    return Calendar.current.dateComponents([.nanosecond], from: startTime, to: endTime).nanosecond!
}

func generateHardToBruteForceSudokusAsync(iterations: Int, maxTimeNanoseconds: Int = 25_000_000, handler: @escaping (_ board: SudokuBoard, _ nanoseconds: Int) -> ()) {
    let serialQueue = DispatchQueue(label: "se.michaelholmgren.SudokuSolver", qos: .userInitiated)
    DispatchQueue.concurrentPerform(iterations: iterations) { _ in
        let board = SudokuBoard.randomStartingBoard()
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

generateMinimalSudokusAsync(iterations: 1_000_000, maxClues: 21) { board in
    print("--> \(board.debugDescription) <-- \(board.clues) clues")
}

//generateHardToBruteForceSudokusAsync(iterations: 10000) { board, nanoseconds in
//    print("--> \(board.debugDescription) <-- \(nanoseconds) nanoseconds - \(board.clues) clues")
//}

