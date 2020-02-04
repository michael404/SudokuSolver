import XCTest

class Sudoku9PerfTests: XCTestCase {
    
    func testPerfSuite() {
        var solutions = [SudokuBoard9]()
        solutions.reserveCapacity(TestData9.perfTestSuite.count * 10)
        self.measure {
            for puzzel in TestData9.perfTestSuite {
                let solvedBoard = try! puzzel.board.findFirstSolution()
                solutions.append(solvedBoard)
            }
        }
        for (solvedBoard, puzzel) in zip(solutions, TestData9.perfTestSuite) {
            XCTAssertEqual(solvedBoard, puzzel.solution)
        }
    }
    
    func testIsValid() {
        self.measure {
            for puzzel in TestData9.perfTestSuite {
                XCTAssertTrue(puzzel.board.isValid)
            }
        }
    }
    
    func testPerfRandomFullyFilledBoard() {
        var board = SudokuBoard9.empty
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
        var board = SudokuBoard9.empty
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


