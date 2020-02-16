import XCTest

class Sudoku9Tests: XCTestCase {
    
    func testInitFromString() {
        let board = SudokuBoard9(TestData9.hard1.string)
        XCTAssertEqual(board, TestData9.hard1.board)
        XCTAssertEqual(board.description, TestData9.hard1.string)
    }
    
    func testIsValid() {
    
        do {
            XCTAssertTrue(TestData9.hard1.board.isValid)
    
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
        
        XCTAssertFalse(TestData9.empty.isValid)
        
        XCTAssertFalse(TestData9.multipleSolutions.isValid)
        
        for puzzel in TestData9.perfTestSuite {
            XCTAssertTrue(puzzel.board.isValid)
        }
        
    }
    
    func testFullyFilled() {
        let filledBoard = TestData9.filled
        XCTAssertEqual(filledBoard.clues, 81)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(filledBoard.findFirstSolution(), filledBoard)
    }
        
    func testFilledCells() {
        XCTAssertEqual(TestData9.hard1.board.clues, 27)
        XCTAssertEqual(TestData9.hard2.board.clues, 21)
        XCTAssertEqual(TestData9.empty.clues, 0)
    }
    
    func testDescription() {
        XCTAssertEqual(TestData9.hard1.board.description, TestData9.hard1.string)
        XCTAssertEqual(TestData9.hard1NiceDescription, TestData9.hard1.board.niceDescription)
    }
    
}
