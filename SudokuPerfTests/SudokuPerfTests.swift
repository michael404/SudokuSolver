import XCTest

class SudokuPerfTests: XCTestCase {
    
    func testPerfSuite() {
        var solutions = [SudokuBoard]()
        solutions.reserveCapacity(TestData.PerfTestSuite.boards.count * 10)
        self.measure {
            for board in TestData.PerfTestSuite.boards {
                let solvedBoard = try! board.findFirstSolution()
                solutions.append(solvedBoard)
            }
        }
        for (solvedBoard, expectedSolution) in zip(solutions, TestData.PerfTestSuite.solutions) {
            XCTAssertEqual(solvedBoard, expectedSolution)
        }
    }
    
    
    func testPerfSuiteGeneric() {
        var solutions = [SudokuBoardGeneric<Sudoku9>]()
        solutions.reserveCapacity(TestDataGeneric9.PerfTestSuite.boards.count * 10)
        self.measure {
            for board in TestDataGeneric9.PerfTestSuite.boards {
                let solvedBoard = try! board.findFirstSolution()
                solutions.append(solvedBoard)
            }
        }
        for (solvedBoard, expectedSolution) in zip(solutions, TestDataGeneric9.PerfTestSuite.solutions) {
            XCTAssertEqual(solvedBoard, expectedSolution)
        }
    }
    
    func testPerfRandomFullyFilledBoard() {
        var board = SudokuBoard.empty
        self.measure {
            let rng = Xoroshiro(seed: (42, 42))
            for _ in 0..<10 {
                board = SudokuBoard.randomFullyFilledBoard(using: rng)
            }
        }
        XCTAssertEqual(board, SudokuBoard("651439728437825691928176435573261984289743516146958372395682147762314859814597263"))
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
    }
    
    func testPerfRandomStartingBoard() {
        var board = SudokuBoard.empty
        self.measure {
            var rng = Xoroshiro(seed: (42, 42))
            for _ in 0..<10 {
                board = SudokuBoard.randomStartingBoard(rng: &rng)
            }
        }
        XCTAssertEqual(board.numberOfSolutions(), .one)
        XCTAssertTrue(board.isValid)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((17...40).contains(board.clues))
    }
}


