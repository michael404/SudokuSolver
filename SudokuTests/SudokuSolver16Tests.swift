import XCTest

class SudokuSolver16Tests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {

        XCTAssertFalse(TestData16.easy1.board.isFullyFilled)
        XCTAssertTrue(TestData16.easy1.board.isValid)
        do {
            let solution = try! TestData16.easy1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData16.easy1.solutionString)
        }
        
        XCTAssertFalse(TestData16.medium1.board.isFullyFilled)
        XCTAssertTrue(TestData16.medium1.board.isValid)
        do {
            let solution = try! TestData16.medium1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData16.medium1.solutionString)
        }
        
        XCTAssertFalse(TestData16.hard1.board.isFullyFilled)
        XCTAssertTrue(TestData16.hard1.board.isValid)
        do {
            let solution = try! TestData16.hard1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData16.hard1.solutionString)
        }
        
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData16.invalid.isValid)
        XCTAssertThrowsError(try TestData16.invalid.findFirstSolution())
    }

    func testFullyFilled() {
        let filledBoard = TestData16.hard1.solution
        XCTAssertEqual(filledBoard.clues, 256)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolution(), filledBoard)

    }

    func testNumberOfSolutions() {
        XCTAssertEqual(TestData16.easy1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData16.medium1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData16.hard1.board.numberOfSolutions(), .one)
        
        XCTAssertEqual(TestData16.invalid.numberOfSolutions(), .none)
        
        XCTAssertEqual(TestData16.multipleSolutions.numberOfSolutions(), .multiple)
        XCTAssertEqual(TestData16.empty.numberOfSolutions(), .multiple)
        
    }
    
    func testConstants() {
        
        XCTAssertEqual(Array(Sudoku16.constants.allIndiciesInRow(0)), Array(0...15))
        XCTAssertEqual(Array(Sudoku16.constants.allIndiciesInRow(1)), Array(16...31))
        XCTAssertEqual(Array(Sudoku16.constants.allIndiciesInRow(15)), Array(240...255))
        
        XCTAssertEqual(Array(Sudoku16.constants.allIndiciesInColumn(0)), [0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240])
        XCTAssertEqual(Array(Sudoku16.constants.allIndiciesInColumn(15)), [15, 31, 47, 63, 79, 95, 111, 127, 143, 159, 175, 191, 207, 223, 239, 255])
        
        XCTAssertEqual(Array(Sudoku16.constants.allIndiciesInBox(3)), [12, 13, 14, 15, 28, 29, 30, 31, 44, 45, 46, 47, 60, 61, 62, 63])
        XCTAssertEqual(Array(Sudoku16.constants.allIndiciesInBox(12)), [192, 193, 194, 195, 208, 209, 210, 211, 224, 225, 226, 227, 240, 241, 242, 243])
        
        XCTAssertEqual(Sudoku16.constants.indiciesAffectedByIndex(196).sorted(), [4, 20, 36, 52, 68, 84, 100, 116, 132, 148, 164, 180, 192, 193, 194, 195, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 212, 213, 214, 215, 228, 229, 230, 231, 244, 245, 246, 247])
        
        XCTAssertEqual(Sudoku16.constants.indiciesInSameRowExclusive(196).sorted(), [192, 193, 194, 195, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207])
        
        XCTAssertEqual(Sudoku16.constants.indiciesInSameColumnExclusive(196).sorted(), [4, 20, 36, 52, 68, 84, 100, 116, 132, 148, 164, 180, 212, 228, 244])
        
        XCTAssertEqual(Sudoku16.constants.indiciesInSameBoxExclusive(196).sorted(), [197, 198, 199, 212, 213, 214, 215, 228, 229, 230, 231, 244, 245, 246, 247])
        
    }
    
//
//    func testRandomFullyFilledBoard() {
//        do {
//            let board = SudokuBoard.randomFullyFilledBoard()
//            XCTAssertEqual(board.numberOfSolutions(), .one)
//            XCTAssertTrue(board.isValid)
//            XCTAssertTrue(board.isFullyFilled)
//        }
//    }
//
//    func testRandomStartingBoard() {
//
//        // Standard RNG
//        do {
//            let board = SudokuBoard.randomStartingBoard()
//            XCTAssertEqual(board.numberOfSolutions(), .one)
//            XCTAssertTrue(board.isValid)
//            XCTAssertFalse(board.isFullyFilled)
//            XCTAssertTrue((17...40).contains(board.clues))
//        }
//
//        // Custom PRNG
//        do {
//            var rng = Xoroshiro()
//            let board = SudokuBoard.randomStartingBoard(rng: &rng)
//            XCTAssertEqual(board.numberOfSolutions(), .one)
//            XCTAssertTrue(board.isValid)
//            XCTAssertFalse(board.isFullyFilled)
//            XCTAssertTrue((17...40).contains(board.clues))
//        }
//    }

        
}

