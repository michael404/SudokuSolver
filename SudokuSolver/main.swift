import Foundation

print("Starting...")

var longestSolvingTimeInNanoseconds = 2_000_000
for _ in 0..<10_000 {
    let board = SudokuBoard.randomStartingBoard()
    //print("  Testing: \(board.debugDescription)")
    do {
        let startTime = Date()
        _ = try board.findFirstSolution()
        let endTime = Date()
        let nanoseconds = Calendar.current.dateComponents([.nanosecond], from: startTime, to: endTime).nanosecond!
        if nanoseconds > longestSolvingTimeInNanoseconds {
            print("--> \(board.debugDescription) <-- \(nanoseconds) nanoseconds - \(board.clues) clues")
            longestSolvingTimeInNanoseconds = nanoseconds
        }
    } catch {
        print("  Not solvable. This should not happen.")
    }
}

