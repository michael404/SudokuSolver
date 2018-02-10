import Foundation

let maxThreads = 4

func generateMinimalSudokusAsync(iterations: Int, maxClues: Int, handler: @escaping (SudokuBoard) -> ()) {
    let concurrentQueue = DispatchQueue.global(qos: .userInitiated)
    let serialQueue = DispatchQueue(label: "se.michaelholmgren.SudokuSolver", qos: .userInitiated)
    let group = DispatchGroup()
    
    //TODO: This rounds down
    let iterationsPerQueue = iterations / maxThreads
    for _ in 0..<maxThreads {
        concurrentQueue.async(group: group) {
            for _ in 0..<iterationsPerQueue {
                let board = SudokuBoard.randomStartingBoard()
                guard board.clues <= maxClues else { continue }
                serialQueue.sync {
                    handler(board)
                }
            }
        }
    }
    group.wait()
}

func generateHardToBruteForceSudokusAsync(iterations: Int, maxTimeNanoseconds: Int = 25_000_000, handler: @escaping (_ board: SudokuBoard, _ nanoseconds: Int) -> ()) {
    let concurrentQueue = DispatchQueue.global(qos: .userInitiated)
    let serialQueue = DispatchQueue(label: "se.michaelholmgren.SudokuSolver", qos: .userInitiated)
    let group = DispatchGroup()
    
    //TODO: This rounds down
    let iterationsPerQueue = iterations / maxThreads
    for _ in 0..<maxThreads {
        concurrentQueue.async(group: group) {
            for _ in 0..<iterationsPerQueue {
                let board = SudokuBoard.randomStartingBoard()
                let startTime = Date()
                guard let _ = try? board.findFirstSolution() else { fatalError("Not solvable. This should not happen.") }
                let endTime = Date()
                let nanoseconds = Calendar.current.dateComponents([.nanosecond], from: startTime, to: endTime).nanosecond!
                guard nanoseconds >= maxTimeNanoseconds else { continue }
                serialQueue.sync {
                    handler(board, nanoseconds)
                }
            }
        }
    }
    group.wait()
}

generateMinimalSudokusAsync(iterations: 100, maxClues: 22) { board in
    print("--> \(board.debugDescription) <-- \(board.clues) clues")
}

generateHardToBruteForceSudokusAsync(iterations: 100) { board, nanoseconds in
    print("--> \(board.debugDescription) <-- \(nanoseconds) nanoseconds - \(board.clues) clues")
}
