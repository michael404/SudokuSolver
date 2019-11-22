import XCTest

class SudokuSIMDPerfTests: XCTestCase {
    
    func testPerfSuiteSubset() {
        let subset = 1..<4
        var results = [SudokuBoardSIMD2x64]()
        let boards = TestData.PerfTestSuite.boards[subset].map(SudokuBoardSIMD2x64.init)
        self.measure {
            for board in boards {
                let solvedBoard = try! board.findFirstSolution()
                results.append(solvedBoard)
            }
        }
        let solutions = TestData.PerfTestSuite.solutions[subset].map(SudokuBoardSIMD2x64.init)
        for (solvedBoard, expectedSolution) in zip(results, solutions) {
            XCTAssertEqual(solvedBoard, expectedSolution)
        }
    }
    
    func testHard() {
        let board = SudokuBoardSIMD2x64(TestData.Hard1.board)
        var result = SudokuBoardSIMD2x64.empty
        self.measure {
            result = try! board.findFirstSolution()
        }
        let solution = SudokuBoardSIMD2x64(TestData.Hard1.solution)
        XCTAssertEqual(result, solution)
    }
    
    func testHard2() {
        let board = SudokuBoardSIMD2x64(TestData.Hard2.board)
        var result = SudokuBoardSIMD2x64.empty
        self.measure {
            result = try! board.findFirstSolution()
        }
        let solution = SudokuBoardSIMD2x64(TestData.Hard2.solution)
        XCTAssertEqual(result, solution)
    }
    
}


