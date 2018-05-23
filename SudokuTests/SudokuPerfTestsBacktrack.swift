import XCTest

class SudokuPerfTestsBacktrack: XCTestCase {
    
    func testPerfSuite() {
        var solutions = [SudokuBoard]()
        self.measure {
            for board in TestData.PerfTestSuite.boards {
                let solvedBoard = try! board.findFirstSolutionBacktrack()
                solutions.append(solvedBoard)
            }
        }
        for (solvedBoard, expectedSolution) in zip(solutions, TestData.PerfTestSuite.solutions) {
            XCTAssertEqual(solvedBoard, expectedSolution)
        }
        
    }
    
    func testPerfMultipleSolutions() {
        var solutions: [SudokuBoard] = []
        self.measure {
            solutions = try! TestData.MultipleSolutions.board.findAllSolutionsBacktrack()
        }
        XCTAssertEqual(solutions.count, 9)
    }
    
    func testPerfRandomFullyFilledBoard() {
        var board = SudokuBoard()
        self.measure {
            var lcrng = LCRNG(seed: 42)
            for _ in 0..<10 {
                board = SudokuBoard.randomFullyFilledBoardBacktrack(rng: &lcrng)
            }
        }
        XCTAssertEqual(board, SudokuBoard("148692537527413986396587124465938271279164853813275649934826715781359462652741398"))
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
    }
    
    func testPerfRandomStartingBoard() {
        var board = SudokuBoard()
        self.measure {
            var lcrng = LCRNG(seed: 0)
            for _ in 0..<10 {
                board = SudokuBoard.randomStartingBoardBacktrack(rng: &lcrng)
            }
        }
        XCTAssertEqual(board, SudokuBoard("8.......2.9...748.7...289..387.6.24.5.9.418.7....83.5.451.7.3.69.83...2.6..19.5.8"))
        XCTAssertTrue(board.isValid)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((17...40).contains(board.clues))
    }
    
    
}

