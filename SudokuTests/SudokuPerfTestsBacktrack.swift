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
            var rng = Xoroshiro(seed: (42, 42))
            for _ in 0..<10 {
                board = SudokuBoard.randomFullyFilledBoardBacktrack(rng: &rng)
            }
        }
        XCTAssertEqual(board, SudokuBoard("365791482249386157187524396423967518658132974791458263574813629936275841812649735"))
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
    }
    
    func testPerfRandomStartingBoard() {
        var board = SudokuBoard()
        self.measure {
            // The performance of this benchmark is very dependent on this seed
            var rng = Xoroshiro(seed: (1, 42))
            for _ in 0..<10 {
                board = SudokuBoard.randomStartingBoardBacktrack(rng: &rng)
            }
        }
        XCTAssertEqual(board.numberOfSolutionsBacktrack(), .one)
        XCTAssertTrue(board.isValid)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((17...40).contains(board.clues))
    }
    
    
}

