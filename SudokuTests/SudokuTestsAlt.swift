import XCTest

class SudokuTestsAlt: XCTestCase {
    
    func testSudokuSolverIntegration() {
        XCTAssertFalse(TestData.board1.isFullyFilled)
        XCTAssertTrue(TestData.board1.isValid)
        
        do {
            let solution = try! TestData.board1.findFirstSolutionAlt()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData.expectedSolution1)
        }
        
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData.invalidBoard.isValid)
        XCTAssertThrowsError(try TestData.invalidBoard.findFirstSolutionAlt())
    }
    
    /*func testFindAllSolutions() {
        do {
            let solutions = try! TestData.board1.findAllSolutions()
            XCTAssertEqual(solutions.count, 1)
            XCTAssertEqual(solutions[0].description, TestData.expectedSolution1)
        }
        
        do {
            // Too many solutions both with default and non-default maxSolutions
            XCTAssertThrowsError(try TestData.emptyBoard.findAllSolutions())
            XCTAssertThrowsError(try TestData.emptyBoard.findAllSolutions(maxSolutions: 50))
        }
        
        do {
            let solutions = try! TestData.multipleSolutionsBoard.findAllSolutions()
            XCTAssertEqual(solutions.count, 9)
            for solution in solutions {
                XCTAssertTrue(solution.isValid)
                XCTAssertTrue(solution.isFullyFilled)
            }
        }
    }*/
    
    /*func testManySolutions() {
        
        //Should throw
        XCTAssertThrowsError(try TestData.multipleSolutionsBoard.findAllSolutions(maxSolutions: 3))
        
        // Should only find 1 solution
        do {
            let solution = try! TestData.board1.findAllSolutions(maxSolutions: 1)
            XCTAssertEqual(solution.count, 1)
            XCTAssertTrue(solution[0].isValid)
            XCTAssertTrue(solution[0].isFullyFilled)
            XCTAssertEqual(solution[0].description, TestData.expectedSolution1)
        }
        
    }*/
    
    /*func testNumberOfSolutions() {
        XCTAssertEqual(TestData.board1.numberOfSolutions(), .one)
        XCTAssertEqual(TestData.board2.numberOfSolutions(), .one)
        XCTAssertEqual(TestData.multipleSolutionsBoard.numberOfSolutions(), .multiple)
        XCTAssertEqual(TestData.invalidBoard.numberOfSolutions(), .none)
    }*/
    
//    func testRandomFullyFilledBoard() {
//        let board = SudokuBoard.randomFullyFilledBoard()
//        XCTAssertTrue(board.isValid)
//        XCTAssertTrue(board.isFullyFilled)
//        XCTAssertEqual(board.clues, 81)
//        
//        
//        // Two random filled boards should (usually) not be equal
//        XCTAssertNotEqual(board, SudokuBoard.randomFullyFilledBoard())
//    }
    
//    func testRandomStartingBoard() {
//        do {
//            let board = SudokuBoard.randomStartingBoard()
//            XCTAssertTrue(board.isValid)
//            XCTAssertFalse(board.isFullyFilled)
//        }
//
//        do {
//            let board = SudokuBoard.randomStartingBoard()
//            XCTAssertTrue(board.isValid)
//            XCTAssertFalse(board.isFullyFilled)
//            XCTAssert(board.clues <= 40) // Maximum that should be possible
//            XCTAssert(board.clues >= 17) // inimum that should be possible
//        }
//
//        // Two random starting boards should (usually) not be equal
//        XCTAssertNotEqual(SudokuBoard.randomStartingBoard(), SudokuBoard.randomStartingBoard())
//    }
    
}

