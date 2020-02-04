import XCTest

class Sudoku25PerfTests: XCTestCase {

    func testSudokuSolverEndToEnd() {
        
        var solution = SudokuBoard25.empty
        
        self.measure {
            solution = try! TestData25.puzzel1.board.findFirstSolution()
        }
        
        XCTAssertTrue(solution.isFullyFilled)
        XCTAssertEqual(solution.description, TestData25.puzzel1.solutionString)
    }
    
    #warning("Understand why this is 3x and not 2x slower than findFirstSolution()")
    func testIsValid() {
        self.measure {
            XCTAssertTrue(TestData25.puzzel1.board.isValid)
        }
    }

}
