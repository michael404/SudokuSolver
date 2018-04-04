import XCTest

class SudokuPerfTestsBacktrack: XCTestCase {
    
    func testPerfNormalSudokus() {
        var solution1 = SudokuBoard()
        var solution2 = SudokuBoard()
        self.measure {
            solution1 = try! TestData.board1.findFirstSolutionBacktrack()
            solution2 = try! TestData.board2.findFirstSolutionBacktrack()
        }
        XCTAssertEqual(solution1.description, TestData.expectedSolution1)
        XCTAssertEqual(solution2.description, TestData.expectedSolution2)
    }
    
    func testPerfHardToBruteForce() {
        var solution = SudokuBoard()
        self.measure {
            solution = try! TestData.hardToBruteForceBoard.findFirstSolutionBacktrack()
        }
        XCTAssertEqual(solution.description, TestData.expectedSolutionHardToBruteForce)
    }
    
    func testPerfMultipleSolutionsBacktrack() {
        var solutions: [SudokuBoard] = []
        self.measure {
            solutions = try! TestData.multipleSolutionsBoard.findAllSolutionsBacktrack()
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

