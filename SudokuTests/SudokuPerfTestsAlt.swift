import XCTest

class SudokuPerfTestsAlt: XCTestCase {
    
    func testPerfNormalSudokus() {
        var solution1 = SudokuBoard()
        var solution2 = SudokuBoard()
        self.measure {
            solution1 = try! TestData.board1.findFirstSolutionAlt()
            solution2 = try! TestData.board2.findFirstSolutionAlt()
        }
        XCTAssertEqual(solution1.description, TestData.expectedSolution1)
        XCTAssertEqual(solution2.description, TestData.expectedSolution2)
    }
    
    func testPerfHardToBruteForce() {
        var solution = SudokuBoard()
        self.measure {
            solution = try! TestData.hardToBruteForceBoard.findFirstSolutionAlt()
        }
        XCTAssertEqual(solution.description, TestData.expectedSolutionHardToBruteForce)
    }
    
//    func testPerfMultipleSolutions() {
//        var solutions: [SudokuBoard] = []
//        self.measure {
//            solutions = try! TestData.multipleSolutionsBoard.findAllSolutions()
//        }
//        XCTAssertEqual(solutions.count, 9)
//    }
//    
//    func testPerfRandomFullyFilledBoard() {
//        var board = SudokuBoard()
//        self.measure {
//            for _ in 0..<10 {
//                board = SudokuBoard.randomFullyFilledBoard()
//            }
//        }
//        XCTAssertTrue(board.isValid)
//        XCTAssertTrue(board.isFullyFilled)
//        XCTAssertEqual(board.clues, 81)
//    }
//    
//    func testPerfRandomStartingBoard() {
//        var board = SudokuBoard()
//        self.measure {
//            for _ in 0..<50 {
//                board = SudokuBoard.randomStartingBoard()
//            }
//        }
//        XCTAssertTrue(board.isValid)
//        XCTAssertFalse(board.isFullyFilled)
//        XCTAssertTrue((17...40).contains(board.clues))
//    }
    
    
}


