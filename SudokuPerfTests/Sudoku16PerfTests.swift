import XCTest

class Sudoku16PerfTests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {
        
        var solution: SudokuBoard16?
        
        self.measure {
            for _ in 0..<50 {
                solution = TestData16.hard1.board.findFirstSolution()
            }
        }
        
        XCTAssertTrue(solution!.isValid)
        XCTAssertTrue(solution!.isFullyFilled)
        XCTAssertEqual(solution!.description, TestData16.hard1.solutionString)
    }
    
    func testIsValid() {
        self.measure {
            for _ in 0..<50 {
                XCTAssertTrue(TestData16.hard1.board.isValid)
            }
        }
    }
    
}
