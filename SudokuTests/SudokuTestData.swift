enum TestData {
    
    static let emptyBoard = SudokuBoard(
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0)
    
    static let board1 = SudokuBoard(
        0, 9, 0,   0, 0, 0,   5, 0, 0,
        0, 0, 1,   8, 9, 0,   0, 2, 4,
        0, 0, 0,   0, 0, 0,   7, 0, 9,
        
        0, 0, 4,   0, 8, 2,   0, 0, 0,
        8, 0, 0,   0, 6, 0,   0, 0, 3,
        0, 0, 0,   3, 5, 0,   2, 0, 0,
        
        5, 0, 9,   0, 0, 0,   0, 0, 0,
        7, 4, 0,   0, 2, 5,   1, 0, 0,
        0, 0, 2,   0, 0, 0,   0, 7, 0)
    
    static let board1String = ".9....5....189..24......7.9..4.82...8...6...3...35.2..5.9......74..251....2....7."
    
    // https://puzzling.stackexchange.com/questions/252/how-do-i-solve-the-worlds-hardest-sudoku
    // http://sw-amt.ws/sudoku/worlds-hardest-sudoku/xx-world-hardest-sudoku.html
    static let board2 = SudokuBoard(
        8, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 3,   6, 0, 0,   0, 0, 0,
        0, 7, 0,   0, 9, 0,   2, 0, 0,
        
        0, 5, 0,   0, 0, 7,   0, 0, 0,
        0, 0, 0,   0, 4, 5,   7, 0, 0,
        0, 0, 0,   1, 0, 0,   0, 3, 0,
        
        0, 0, 1,   0, 0, 0,   0, 6, 8,
        0, 0, 8,   5, 0, 0,   0, 1, 0,
        0, 9, 0,   0, 0, 0,   4, 0, 0)
    
    // https://www.flickr.com/photos/npcomplete/2361922699
    static let hardToBruteForceBoard = SudokuBoard(
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 3,   0, 8, 5,
        0, 0, 1,   0, 2, 0,   0, 0, 0,
        
        0, 0, 0,   5, 0, 7,   0, 0, 0,
        0, 0, 4,   0, 0, 0,   1, 0, 0,
        0, 9, 0,   0, 0, 0,   0, 0, 0,
        
        5, 0, 0,   0, 0, 0,   0, 7, 3,
        0, 0, 2,   0, 1, 0,   0, 0, 0,
        0, 0, 0,   0, 4, 0,   0, 0, 9)
    
    static let multipleSolutionsBoard = SudokuBoard(
        0, 9, 0,   0, 0, 0,   5, 0, 0,
        0, 0, 1,   8, 9, 0,   0, 2, 4,
        0, 0, 0,   0, 0, 0,   7, 0, 9,
        
        0, 0, 4,   0, 8, 2,   0, 0, 0,
        8, 0, 0,   0, 6, 0,   0, 0, 3,
        0, 0, 0,   3, 5, 0,   2, 0, 0,
        
        5, 0, 9,   0, 0, 0,   0, 0, 0,
        7, 4, 0,   0, 2, 5,   1, 0, 0,
        0, 0, 2,   0, 0, 0,   0, 0, 0)
    
    static let invalidBoard = SudokuBoard(
        0, 0, 0,    0, 0, 0,    0, 0, 6,
        0, 0, 0,    0, 0, 3,    0, 0, 0,
        0, 0, 0,    0, 0, 0,    6, 0, 0,
        
        0, 0, 0,    0, 0, 0,    0, 0, 0,
        0, 0, 0,    0, 0, 0,    6, 0, 0,
        0, 0, 0,    0, 0, 0,    7, 0, 0,
        
        0, 0, 0,    0, 9, 0,    0, 6, 0,
        0, 0, 0,    0, 0, 0,    0, 0, 0,
        0, 0, 0,    6, 0, 0,    0, 0, 2)
    
    static let filledboard = SudokuBoard("739561842468237951251498673517349286943826715826715394675182439194673528382954167")
    
    static let expectedSolution1 = """
        +-----+-----+-----+
        |4 9 7|2 3 6|5 8 1|
        |6 5 1|8 9 7|3 2 4|
        |2 8 3|5 4 1|7 6 9|
        +-----+-----+-----+
        |9 3 4|1 8 2|6 5 7|
        |8 2 5|7 6 9|4 1 3|
        |1 7 6|3 5 4|2 9 8|
        +-----+-----+-----+
        |5 1 9|6 7 3|8 4 2|
        |7 4 8|9 2 5|1 3 6|
        |3 6 2|4 1 8|9 7 5|
        +-----+-----+-----+
        
        """
    
    static let expectedSolution2 = """
        +-----+-----+-----+
        |8 1 2|7 5 3|6 4 9|
        |9 4 3|6 8 2|1 7 5|
        |6 7 5|4 9 1|2 8 3|
        +-----+-----+-----+
        |1 5 4|2 3 7|8 9 6|
        |3 6 9|8 4 5|7 2 1|
        |2 8 7|1 6 9|5 3 4|
        +-----+-----+-----+
        |5 2 1|9 7 4|3 6 8|
        |4 3 8|5 2 6|9 1 7|
        |7 9 6|3 1 8|4 5 2|
        +-----+-----+-----+

        """
    
    static let expectedSolutionHardToBruteForce = """
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
    
    
}
