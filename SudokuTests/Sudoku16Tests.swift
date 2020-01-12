import XCTest

class Sudoku16Tests: XCTestCase {

    func testInitFromString() {
        let board = SudokuBoard16(TestData16.Hard1.string)
        XCTAssertEqual(board, TestData16.Hard1.board)
        XCTAssertEqual(board.description, TestData16.Hard1.string)
    }

    func testIsValid() {

        XCTAssertTrue(TestData16.Easy1.board.isValid)
        XCTAssertTrue(TestData16.Medium1.board.isValid)
        XCTAssertTrue(TestData16.Hard1.board.isValid)
        XCTAssertFalse(TestData16.Invalid.board.isValid)
        XCTAssertFalse(TestData16.Empty.board.isValid)

    }

    func testFullyFilled() {
        let filledBoard = TestData16.Hard1.solution
        XCTAssertEqual(filledBoard.clues, 256)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolution(), filledBoard)
    }
        
    func testFilledCells() {
        XCTAssertEqual(TestData16.Hard1.board.clues, 90)
        XCTAssertEqual(TestData16.Empty.board.clues, 0)
    }

    func testDescription() {
        XCTAssertEqual(TestData16.Hard1.board.description, TestData16.Hard1.string)
    }

}
