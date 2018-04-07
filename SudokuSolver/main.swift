import Foundation


func generateMinimalSudokusAsync(iterations: Int, maxClues: Int, handler: @escaping (SudokuBoard) -> ()) {
    let serialQueue = DispatchQueue(label: "se.michaelholmgren.SudokuSolver", qos: .userInitiated)
    DispatchQueue.concurrentPerform(iterations: iterations) { _ in
        let board = SudokuBoard.randomStartingBoardBacktrack()
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
        let board = SudokuBoard.randomStartingBoardBacktrack()
        let nanoseconds = countNanoseconds {
            guard board.numberOfSolutionsBacktrack() == .one else {
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


//do {
//    let solution1 = try TestData.constraintPropagationSolvableBoard.findFirstSolutionAlt()
//    withExtendedLifetime(solution1) {}
////    print(solution1)
//} catch {
//    print("Error during solving of board1")
//}
//
//print("+++++++++++++++++++++++++++++++++++++++++++++++")
//
//let board1 = TestData.board1
//let expectedSolution1 = TestData.expectedSolution1
//
//for _ in 0..<100 {
//    do {
//        let solution1 = try board1.findFirstSolutionAlt()
//        withExtendedLifetime(solution1) {}
////        print(solution1)
//        precondition(solution1.description == expectedSolution1)
//    } catch {
//        print("Error during solving of board2")
//    }
//}

var reversed = Dictionary<Int, [Int]>()
for i in 0...80 {
    for j in PossibleCellValuesBoard.indiciesThatNeedToBeCheckedWhenChanging(index: i) {
        reversed[j, default: []].append(i)
    }
}
print(reversed[0]!)
