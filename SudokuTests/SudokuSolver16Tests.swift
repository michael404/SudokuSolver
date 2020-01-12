import XCTest

class SudokuSolver16Tests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {

        XCTAssertFalse(TestData16.Easy1.board.isFullyFilled)
        XCTAssertTrue(TestData16.Easy1.board.isValid)
        do {
            let solution = try! TestData16.Easy1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData16.Easy1.solutionString)
        }
        
        XCTAssertFalse(TestData16.Medium1.board.isFullyFilled)
        XCTAssertTrue(TestData16.Medium1.board.isValid)
        do {
            let solution = try! TestData16.Medium1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData16.Medium1.solutionString)
        }
        
        XCTAssertFalse(TestData16.Hard1.board.isFullyFilled)
        XCTAssertTrue(TestData16.Hard1.board.isValid)
        do {
            let solution = try! TestData16.Hard1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData16.Hard1.solutionString)
        }
        
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData16.Invalid.board.isValid)
        XCTAssertThrowsError(try TestData16.Invalid.board.findFirstSolution())
    }

    func testFullyFilled() {
        let filledBoard = TestData16.Hard1.solution
        XCTAssertEqual(filledBoard.clues, 256)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolution(), filledBoard)

    }

    func testNumberOfSolutions() {
        XCTAssertEqual(TestData16.Easy1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData16.Medium1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData16.Hard1.board.numberOfSolutions(), .one)
        
        XCTAssertEqual(TestData16.Invalid.board.numberOfSolutions(), .none)
        
        XCTAssertEqual(TestData16.MultipleSolutions.board.numberOfSolutions(), .multiple)
        XCTAssertEqual(TestData16.Empty.board.numberOfSolutions(), .multiple)
        
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

