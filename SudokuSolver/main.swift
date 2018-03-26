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

//generateMinimalSudokusAsync(iterations: 1_000_000, maxClues: 28) { board in
//    print("--> \(board.debugDescription) <-- \(board.clues) clues")
//}

//generateHardToBruteForceSudokusAsync(iterations: 10000) { board, nanoseconds in
//    print("--> \(board.debugDescription) <-- \(nanoseconds) nanoseconds - \(board.clues) clues")
//}



// Sudoku that can be solved with constraint propagation only
var board1 = SudokuBoard("9.4286....581...69..1..382418..9.74.7634..2.....7356.859.861...3.7.2..86.1..7.952")

do {
    let solution1 = try board1.findFirstSolutionAlt()
    print(solution1)
} catch {
    print("Error during solving of board1")
}

print("+++++++++++++++++++++++++++++++++++++++++++++++")

let board = SudokuBoard(
    0, 0, 0,   0, 0, 0,   0, 0, 0,
    0, 0, 0,   0, 0, 3,   0, 8, 5,
    0, 0, 1,   0, 2, 0,   0, 0, 0,
    
    0, 0, 0,   5, 0, 7,   0, 0, 0,
    0, 0, 4,   0, 0, 0,   1, 0, 0,
    0, 9, 0,   0, 0, 0,   0, 0, 0,
    
    5, 0, 0,   0, 0, 0,   0, 7, 3,
    0, 0, 2,   0, 1, 0,   0, 0, 0,
    0, 0, 0,   0, 4, 0,   0, 0, 9)

let expectedSolution1 = """
+-----+-----+-----+
|9 8 7|6 5 4|3 2 1|
|2 4 6|1 7 3|9 8 5|
|3 5 1|9 2 8|7 4 6|
+-----+-----+-----+
|1 2 8|5 3 7|6 9 4|
|6 3 4|8 9 2|1 5 7|
|7 9 5|4 6 1|8 3 2|
+-----+-----+-----+
|5 1 9|2 8 6|4 7 3|
|4 7 2|3 1 9|5 6 8|
|8 6 3|7 4 5|2 1 9|
+-----+-----+-----+

"""

for _ in 0..<10 {
    do {
        let solution2 = try board.findFirstSolutionAlt()
        print(solution2)
        precondition(solution2.description == expectedSolution1)
    } catch {
        print("Error during solving of board2")
    }
}

