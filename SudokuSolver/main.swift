import Foundation
import Dispatch

let oq = OperationQueue()
oq.maxConcurrentOperationCount = 2

var sema = DispatchSemaphore(value: 0)

var result1: Int?
var result2: Int?

oq.addOperation {
    var longestSolvingTimeInNanoseconds = 2_000_000
    for _ in 0..<100000 {
        let board = SudokuBoard.randomStartingBoard()
        //print("  Testing: \(board.debugDescription)")
        do {
            let startTime = Date()
            _ = try board.findFirstSolution()
            let endTime = Date()
            let nanoseconds = Calendar.current.dateComponents([.nanosecond], from: startTime, to: endTime).nanosecond!
            if nanoseconds > longestSolvingTimeInNanoseconds {
                print("1 --> \(board.debugDescription) <- \(nanoseconds) nanoseconds")
                longestSolvingTimeInNanoseconds = nanoseconds
            }
        } catch {
            print("  Not solvable. This should not happen.")
        }

    }
    result1 = longestSolvingTimeInNanoseconds
    sema.signal()
    print("oq1 finished")
}

oq.addOperation {
    var longestSolvingTimeInNanoseconds = 2_000_000
    for _ in 0..<10000 {
        let board = SudokuBoard.randomStartingBoard()
        //print("  Testing: \(board.debugDescription)")
        do {
            let startTime = Date()
            _ = try board.findFirstSolution()
            let endTime = Date()
            let nanoseconds = Calendar.current.dateComponents([.nanosecond], from: startTime, to: endTime).nanosecond!
            if nanoseconds > longestSolvingTimeInNanoseconds {
                print("2 --> \(board.debugDescription) <- \(nanoseconds) nanoseconds")
                longestSolvingTimeInNanoseconds = nanoseconds
            }
        } catch {
            print("  Not solvable. This should not happen.")
        }
    }
    result2 = longestSolvingTimeInNanoseconds
    sema.signal()
    print("oq2 finished")
}

sema.wait()
oq.cancelAllOperations()

if let result = result1 {
    print("Result from OQ 1: \(result)")
} else if let result = result2 {
    print("Result from OQ 2: \(result)")
} else {
    fatalError("This should not happen")
}

print("finished")

