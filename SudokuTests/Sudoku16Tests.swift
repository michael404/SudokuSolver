import XCTest

class Sudoku16Tests: XCTestCase {

    func testInitFromString() {
        let board = try! SudokuBoard16(TestData16.hard1.string)
        XCTAssertEqual(board, TestData16.hard1.board)
        XCTAssertEqual(board.description, TestData16.hard1.string)
    }

    func testHasUniqueSolution() {

        XCTAssertTrue(TestData16.easy1.board.hasUniqueSolution)
        XCTAssertTrue(TestData16.medium1.board.hasUniqueSolution)
        XCTAssertTrue(TestData16.hard1.board.hasUniqueSolution)
        XCTAssertFalse(TestData16.invalid.hasUniqueSolution)
        XCTAssertFalse(TestData16.empty.hasUniqueSolution)

    }

    func testFullyFilled() {
        let filledBoard = TestData16.hard1.solution
        XCTAssertEqual(filledBoard.clues, 256)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(filledBoard.findFirstSolution(), filledBoard)
    }
        
    func testFilledCells() {
        XCTAssertEqual(TestData16.hard1.board.clues, 90)
        XCTAssertEqual(TestData16.empty.clues, 0)
    }

    func testDescription() {
        XCTAssertEqual(TestData16.hard1.board.description, TestData16.hard1.string)
    }

}
