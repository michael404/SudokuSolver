import XCTest

class Sudoku25PerfTests: XCTestCase {

    func testSudokuSolverEndToEnd() {
        
        var solution: SudokuBoard25?
        
        self.measure {
            solution = TestData25.puzzel1.board.findFirstSolution()
        }
        
        XCTAssertTrue(solution!.isFullyFilled)
        XCTAssertEqual(solution!.description, TestData25.puzzel1.solutionString)
    }
    
    func testIsValid() {
        self.measure {
            XCTAssertTrue(TestData25.puzzel1.board.isValid)
        }
    }

}
