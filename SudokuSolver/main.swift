import Foundation

extension Int {
    static func random(_ from: Int, _ to: Int) -> Int {
        return from + numericCast(arc4random_uniform(numericCast(to - from)))
    }
}

var validStartingBoards: [SudokuBoard] = []

for _ in 0..<1000 {
    var board = SudokuBoard()
    for _ in 0..<Int.random(8, 25) {
        board[Int.random(0,8), Int.random(0,8)] = SudokuCell(Int.random(1,9))
    }
    do {
        let solver = try SudokuSolver(board)
        _ = try solver.solve()
        validStartingBoards.append(board)
    } catch _ {
        continue
    }
}

print(validStartingBoards.count)
print(validStartingBoards)
