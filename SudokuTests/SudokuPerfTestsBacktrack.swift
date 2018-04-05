import XCTest

class SudokuPerfTestsBacktrack: XCTestCase {
    
    func testPerfNormalSudokus() {
        var solution1 = SudokuBoard()
        var solution2 = SudokuBoard()
        self.measure {
            solution1 = try! TestData.Hard1.board.findFirstSolutionBacktrack()
            solution2 = try! TestData.Hard2.board.findFirstSolutionBacktrack()
        }
        XCTAssertEqual(solution1.description, TestData.Hard1.solutionString)
        XCTAssertEqual(solution2.description, TestData.Hard2.solutionString)
    }
    
    func testPerfCEOptimized() {
        var solution = SudokuBoard()
        self.measure {
            solution = try! TestData.ConstraintPropagationSolvable.board.findFirstSolutionConstraintElimination()
        }
        XCTAssertEqual(solution, TestData.ConstraintPropagationSolvable.solution)
    }
    
    func testPerfHardToBruteForce() {
        var solution = SudokuBoard()
        self.measure {
            solution = try! TestData.HardToBruteForce.board.findFirstSolutionBacktrack()
        }
        XCTAssertEqual(solution.description, TestData.HardToBruteForce.solutionString)
    }
    
    func testPerfMultipleSolutionsBacktrack() {
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

