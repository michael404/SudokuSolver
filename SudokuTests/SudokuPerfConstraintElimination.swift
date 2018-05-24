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
            var rng = Xoroshiro(seed: (42, 42))
            for _ in 0..<10 {
                board = SudokuBoard.randomFullyFilledBoardCE(rng: &rng)
            }
        }
        XCTAssertEqual(board, SudokuBoard("983624571421587369567931482854196237239758614716243958145862793672319845398475126"))
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
    }
}


