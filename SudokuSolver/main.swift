let sb = SudokuBoard(
    0, 9, 0,   0, 0, 0,   5, 0, 0,
    0, 0, 1,   8, 9, 0,   0, 2, 4,
    0, 0, 0,   0, 0, 0,   7, 0, 9,

    0, 0, 4,   0, 8, 2,   0, 0, 0,
    8, 0, 0,   0, 6, 0,   0, 0, 3,
    0, 0, 0,   3, 5, 0,   2, 0, 0,

    5, 0, 9,   0, 0, 0,   0, 0, 0,
    7, 4, 0,   0, 2, 5,   1, 0, 0,
    0, 0, 2,   0, 0, 0,   0, 7, 0)

print(sb)

print("Board is valid: \(sb.isValid())")
print("Board is filled: \(sb.isFullyFilled())")
print()

var solver = try! SudokuSolver(sb)
let solution = try! solver.solve()
print("Found solution!")
print(solution)

