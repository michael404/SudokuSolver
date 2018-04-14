import XCTest

class SudokuPerfConstraintElimination: XCTestCase {
    
    func testPerfSuite() {
        var solutions = [SudokuBoard]()
        self.measure {
            for board in TestData.PerfTestSuite.boards {
                let solvedBoard = try! board.findFirstSolutionConstraintElimination()
                solutions.append(solvedBoard)
            }
        }
        for (solvedBoard, expectedSolution) in zip(solutions, TestData.PerfTestSuite.solutions) {
            XCTAssertEqual(solvedBoard, expectedSolution)
        }
    }
    
    func testPerfRandomFullyFilledBoardCE() {
        var board = SudokuBoard()
        self.measure {
            for _ in 0..<10 {
                board = SudokuBoard.randomFullyFilledBoardCE()
            }
        }
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
    }
}


