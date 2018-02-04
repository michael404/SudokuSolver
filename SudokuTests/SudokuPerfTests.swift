import XCTest

class SudokuPerfTests: XCTestCase {
    
    func testPerfNormalSudokusFromStart() {
        var solution1 = SudokuBoard()
        var solution2 = SudokuBoard()
        self.measure {
            solution1 = try! TestData.board1.findFirstSolution(method: .fromStart)
            solution2 = try! TestData.board2.findFirstSolution(method: .fromStart)
        }
        XCTAssertEqual(solution1.description, TestData.expectedSolution1)
        XCTAssertEqual(solution2.description, TestData.expectedSolution2)
    }
    
    func testPerfHardToBruteForceFromStart() {
        var solution = SudokuBoard()
        self.measure {
            solution = try! TestData.hardToBruteForceBoard.findFirstSolution(method: .fromStart)
        }
        XCTAssertEqual(solution.description, TestData.expectedSolutionHardToBruteForce)
    }
    
    func testPerfNormalSudokusFromRowWithMostFilledValues() {
        var solution1 = SudokuBoard()
        var solution2 = SudokuBoard()
        self.measure {
            solution1 = try! TestData.board1.findFirstSolution(method: .fromRowWithMostFilledValues)
            solution2 = try! TestData.board2.findFirstSolution(method: .fromRowWithMostFilledValues)
        }
        XCTAssertEqual(solution1.description, TestData.expectedSolution1)
        XCTAssertEqual(solution2.description, TestData.expectedSolution2)
    }
    
    func testPerfHardToBruteForceFromRowWithMostFilledValues() {
        var solution = SudokuBoard()
        self.measure {
            solution = try! TestData.hardToBruteForceBoard.findFirstSolution(method: .fromRowWithMostFilledValues)
        }
        XCTAssertEqual(solution.description, TestData.expectedSolutionHardToBruteForce)
    }
    
    func testPerfMultipleSolutions() {
        var solutions: [SudokuBoard] = []
        self.measure {
            solutions = try! TestData.multipleSolutionsBoard.findAllSolutions()
        }
        XCTAssertEqual(solutions.count, 9)
    }
    
}
