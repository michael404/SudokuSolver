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
            var lcrng = LCRNG(seed: 42)
            for _ in 0..<10 {
                board = SudokuBoard.randomFullyFilledBoardCE(rng: &lcrng)
            }
        }
        XCTAssertEqual(board, SudokuBoard("458392716612857493937164825274639158861475239593218674326581947189743562745926381"))
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
    }
}


