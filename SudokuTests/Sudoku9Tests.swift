import XCTest

class Sudoku9Tests: XCTestCase {
    
    func testInitFromString() {
        let board = SudokuBoard9(TestData9.Hard1.string)
        XCTAssertEqual(board, TestData9.Hard1.board)
        XCTAssertEqual(board.description, TestData9.Hard1.string)
    }
    
    func testIsValid() {
    
        do {
            XCTAssertTrue(TestData9.Hard1.board.isValid)
    
            let nonValid = SudokuBoard9("99....5....189..24......7.9..4.82...8...6...3...35.2..5.9......74..251....2....7.")
            XCTAssertFalse(nonValid.isValid)
        }
        do {
            let nonValid = SudokuBoard9(".9....5....189..24......7.9..4.82...8...6...3...35.2..5.9......74..255....2....7.")
            XCTAssertFalse(nonValid.isValid)
        }
        do {
            let nonValid = SudokuBoard9(".9....5...9189..24......7.9..4.82...8...6...3...35.2..5.9......74..251....2....7.")
            XCTAssertFalse(nonValid.isValid)
        }
        do {
            let nonValid = SudokuBoard9("55...............................................................................")
            XCTAssertFalse(nonValid.isValid)
        }
        do {
            let nonValid = SudokuBoard9(".....................................................................9..........9")
            XCTAssertFalse(nonValid.isValid)
        }
        
        XCTAssertFalse(TestData9.Empty.board.isValid)
        
        XCTAssertFalse(TestData9.MultipleSolutions.board.isValid)
        
        for board in TestData9.PerfTestSuite.boards {
            XCTAssertTrue(board.isValid)
        }
        
    }
    
    func testFullyFilled() {
        let filledBoard = TestData9.Filled.board
        XCTAssertEqual(filledBoard.clues, 81)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolution(), filledBoard)
    }
        
    func testFilledCells() {
        XCTAssertEqual(TestData9.Hard1.board.clues, 27)
        XCTAssertEqual(TestData9.Hard2.board.clues, 21)
        XCTAssertEqual(TestData9.Empty.board.clues, 0)
    }
    
    func testDescription() {
        XCTAssertEqual(TestData9.Hard1.board.description, TestData9.Hard1.string)
        XCTAssertEqual(TestData9.Hard1.board.niceDescription, TestData9.Hard1.niceDescription)
    }
    
}
