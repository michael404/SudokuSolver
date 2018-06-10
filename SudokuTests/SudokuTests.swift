import XCTest

class SudokuTests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {
        XCTAssertFalse(TestData.Hard1.board.isFullyFilled)
        XCTAssertTrue(TestData.Hard1.board.isValid)
        
        do {
            let solution = try! TestData.Hard1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData.Hard1.solutionString)
        }
    }
    
    func testInitFromString() {
        let board = SudokuBoard(TestData.Hard1.string)
        XCTAssertEqual(board, TestData.Hard1.board)
        XCTAssertEqual(board.debugDescription, TestData.Hard1.string)
    }
    
    func testIsValid() {
    
        do {
            XCTAssertTrue(TestData.Hard1.board.isValid)
    
            var board1NonValid = TestData.Hard1.board
            board1NonValid[0, 0] = 9
            XCTAssertFalse(board1NonValid.isValid)
    
            board1NonValid = TestData.Hard1.board
            board1NonValid[8, 6] = 5
            XCTAssertFalse(board1NonValid.isValid)
    
            board1NonValid = TestData.Hard1.board
            board1NonValid[6, 7] = 1
            XCTAssertFalse(board1NonValid.isValid)
        }
        
        do {
            var board = SudokuBoard()
            board[0, 0] = 5
            board[0, 1] = 5
            XCTAssertFalse(board.isValid)
            
            board = SudokuBoard()
            board[0, 8] = 9
            board[2, 6] = 9
            XCTAssertFalse(board.isValid)
            
        }
        
        XCTAssertFalse(TestData.MultipleSolutions.board.isValid)
        
        for board in TestData.PerfTestSuite.boards {
            XCTAssertTrue(board.isValid)
        }
        
    }
    
    func testFullyFilled() {
        let filledBoard = TestData.Filled.board
        XCTAssertEqual(filledBoard.clues, 81)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolution(), filledBoard)
    }
    

    
    func testFilledCells() {
        XCTAssertEqual(TestData.Hard1.board.clues, 27)
        XCTAssertEqual(TestData.Hard2.board.clues, 21)
        XCTAssertEqual(TestData.Empty.board.clues, 0)
    }
    
}
