import XCTest

class SudokuGenericTests: XCTestCase {

    func testInitFromString() {
        let board = SudokuBoardGeneric<Sudoku16>(TestDataGeneric16.Hard1.string)
        XCTAssertEqual(board, TestDataGeneric16.Hard1.board)
        XCTAssertEqual(board.description, TestDataGeneric16.Hard1.string)
    }

    func testIsValid() {

        XCTAssertTrue(TestDataGeneric16.Easy1.board.isValid)
        XCTAssertTrue(TestDataGeneric16.Medium1.board.isValid)
        XCTAssertTrue(TestDataGeneric16.Hard1.board.isValid)
        XCTAssertFalse(TestDataGeneric16.Invalid.board.isValid)
        XCTAssertFalse(TestDataGeneric16.Empty.board.isValid)

    }

    func testFullyFilled() {
        let filledBoard = TestDataGeneric16.Hard1.solution
        XCTAssertEqual(filledBoard.clues, 256)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolution(), filledBoard)
    }
        
    func testFilledCells() {
        XCTAssertEqual(TestDataGeneric16.Hard1.board.clues, 90)
        XCTAssertEqual(TestDataGeneric16.Empty.board.clues, 0)
    }

    func testDescription() {
        XCTAssertEqual(TestDataGeneric16.Hard1.board.description, TestDataGeneric16.Hard1.string)
    }

}
