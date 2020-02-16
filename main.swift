
var board = SudokuBoard<Sudoku25>(String.init(repeating: ".", count: 25*25))
print(board.numberOfSolutions())
print(board)
let solved = board.findFirstSolution()!
print(solved)


var board2 = SudokuBoard<Sudoku25>("Q..M.PW.U..I.Y...BVN.A..XG.F.P..Q..R....T...H.CD..W...CHT....K..D.I...M....KE.JX..MA..LO.U.W.Q..G.I.....O.D..V...BAL.U...Q...L..SQAEV.W..Y....N....XJ.UXW.DS..I.LF..KRQ.JAPHYG...Y....UG.OX..H.V...F....PI......OKT..C.U.GB....R...N.FTX....U.I..YM..Q.S.......U.WP....N.Y...E.SA..TBPWLQ..V.G.M...U..D....O.V..G.C.....HQ..O........S.A......D.OEK..C..J.Y.W..O.R..A.Y.D...C.BS..JI......NW...Q.MD..Y...OXIFGT.H...RYM...J.KL...D..XW....J..MI.F.XU..O.W...RK..SY..O.Y.PBD.E..A.J....C..HN.FIG.OV..CPBQ..E......MDA.MH..J..C.......TX.Y.RQ.S..KDA.NHW.....TVP..I...E.IN...XO..B.R.H.C.EU..KJ....BO....F.S.AUEH.JWQ...XM...FV..TK...C...R.DS..PA.")
print(board2)
print(board2.numberOfSolutions())
let solved2 = board2.findFirstSolution()!
print(solved2)


//print(SudokuBoard<Sudoku25>.randomStartingBoard())

//generateMinimalSudokusAsync(iterations: 1_000_000, maxClues: 20, type: Sudoku9.self) { board in
//    print("--> \(board.description) <-- \(board.clues) clues")
//}
//
//generateHardToBruteForceSudokusAsync(iterations: 1_000_000, type: Sudoku16.self) { board, nanoseconds in
//    print("--> \(board.description) <-- \(nanoseconds) nanoseconds - \(board.clues) clues")
//}
