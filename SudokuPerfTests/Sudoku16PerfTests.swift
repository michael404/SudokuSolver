import XCTest

class Sudoku16PerfTests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {
        
        var solution = SudokuBoard16.empty
        
        self.measure {
            for _ in 0..<50 {
                solution = try! TestData16.Hard1.board.findFirstSolution()
            }
        }
        
        XCTAssertTrue(solution.isValid)
        XCTAssertTrue(solution.isFullyFilled)
        XCTAssertEqual(solution.description, TestData16.Hard1.solutionString)
    }
    
    func testSudokuSolverEndToEndGeneric() {
        
        var solution = SudokuBoardGeneric<Sudoku16>.empty
        
        self.measure {
            for _ in 0..<50 {
                solution = try! TestDataGeneric16.Hard1.board.findFirstSolution()
            }
        }
        
        XCTAssertTrue(solution.isValid)
        XCTAssertTrue(solution.isFullyFilled)
        XCTAssertEqual(solution.description, TestData16.Hard1.solutionString)
    }
    
}
