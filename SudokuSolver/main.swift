var sb = SudokuBoard([
    
    .empty, .s9, .empty, .empty, .empty, .empty, .s5, .empty, .empty,
    .empty, .empty, .s1, .s8, .s9, .empty, .empty, .s2, .s4,
    .empty, .empty, .empty, .empty, .empty, .empty, .s7, .empty, .s9,
    
    .empty, .empty, .s4, .empty, .s8, .s2, .empty, .empty, .empty,
    .s8, .empty, .empty, .empty, .s6, .empty, .empty, .empty, .s3,
    .empty, .empty, .empty, .s3, .s5, .empty, .s2, .empty, .empty,
    
    .s5, .empty, .s9, .empty, .empty, .empty, .empty, .empty, .empty,
    .s7, .s4, .empty, .empty, .s2, .s5, .s1, .empty, .empty,
    .empty, .empty, .s2, .empty, .empty, .empty, .empty, .s7, .empty
    
    ])

//sb[0, 0] = .s1
//sb[0, 1] = .s2
//sb[1, 0] = .s4
//sb[0, 2] = .s3
//sb[0, 3] = .s4
//sb[8, 8] = .s9
//sb[4, 4] = .s9

print(sb)

print("Board is valid: \(sb.isValid())")
print("Board is filled: \(sb.isFullyFilled())")
print()

var solver = try! SudokuSolver(sb)
let solution = try! solver.solve()
print("Found solution!")
print(solution)

