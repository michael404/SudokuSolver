import XCTest

class Sudoku16PerfTests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {
        
        var solution = SudokuBoard16.empty
        
        self.measure {
            solution = try! TestData16.Hard1.board.findFirstSolution()
        }
        
        XCTAssertTrue(solution.isValid)
        XCTAssertTrue(solution.isFullyFilled)
        XCTAssertEqual(solution.description, TestData16.Hard1.solutionString)
    }
}
