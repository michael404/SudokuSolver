import XCTest

class SudokuTests: XCTestCase {
    
    func testInitFromString() {
        let board = SudokuBoard(TestData.Hard1.string)
        XCTAssertEqual(board, TestData.Hard1.board)
        XCTAssertEqual(board.debugDescription, TestData.Hard1.string)
    }
    
    func testIsValid() {
    
        do {
            XCTAssertTrue(TestData.Hard1.board.isValid)
    
            let nonValid = SudokuBoard("99....5....189..24......7.9..4.82...8...6...3...35.2..5.9......74..251....2....7.")
            XCTAssertFalse(nonValid.isValid)
        }
        do {
            let nonValid = SudokuBoard(".9....5....189..24......7.9..4.82...8...6...3...35.2..5.9......74..255....2....7.")
            XCTAssertFalse(nonValid.isValid)
        }
        do {
            let nonValid = SudokuBoard(".9....5...9189..24......7.9..4.82...8...6...3...35.2..5.9......74..251....2....7.")
            XCTAssertFalse(nonValid.isValid)
        }
        do {
            let nonValid = SudokuBoard("55...............................................................................")
            XCTAssertFalse(nonValid.isValid)
        }
        do {
            let nonValid = SudokuBoard(".....................................................................9..........9")
            XCTAssertFalse(nonValid.isValid)
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
    
    func testDescription() {
        XCTAssertEqual(TestData.Hard1.board.description, TestData.Hard1.description)
        XCTAssertEqual(TestData.Hard1.board.debugDescription, TestData.Hard1.string)
    }
    
}
