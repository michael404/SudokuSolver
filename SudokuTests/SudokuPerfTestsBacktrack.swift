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
            for _ in 0..<10 {
                board = SudokuBoard.randomFullyFilledBoardBacktrack()
            }
        }
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
    }
    
    //TODO: Add a PRNG implementation to make this less variable
    func testPerfRandomStartingBoard() {
        var board = SudokuBoard()
        self.measure {
            for _ in 0..<50 {
                board = SudokuBoard.randomStartingBoardBacktrack()
            }
        }
        XCTAssertTrue(board.isValid)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((17...40).contains(board.clues))
    }
    
    
}

