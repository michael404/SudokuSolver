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
    
    func testBitMask() {
        let a = SudokuValidator.Mask()
        for i in 0..<10 {
            for j in 0..<10 {
                XCTAssertFalse(a[i, j])
            }
        }
        var c = SudokuValidator.Mask()
        for i in 0...9 {
            c[0,i] = true
            XCTAssertTrue(c[0,i])
        }
        for i in 0...9 {
            XCTAssertFalse(c[1,i])
        }
        c[2,0] = true
        XCTAssertTrue(c[2,0])
        for i in 1...9 {
            XCTAssertFalse(c[2,i])
        }
        c[3,0] = true
        XCTAssertTrue(c[3,0])
        for i in 1...9 {
            XCTAssertFalse(c[3,i])
        }
        c[4,1] = true
        XCTAssertTrue(c[4,1])
        c[4,1] = false
        XCTAssertFalse(c[4,1])
        for i in 2...50 {
            XCTAssertFalse(c[4,i])
        }
    }
    
}
