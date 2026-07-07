import XCTest

class Sudoku16PerfTests: XCTestCase {

    private static let solverSeeds: [UInt64] = [16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
    
    func testSudokuSolverEndToEnd() {
        
        var solution: SudokuBoard16?
        
        self.measure {
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                for _ in 0..<50 {
                    solution = TestData16.hard1.board.findFirstSolution(using: &rng)
                }
            }
        }
        
        XCTAssertTrue(solution!.hasUniqueSolution)
        XCTAssertTrue(solution!.isFullyFilled)
        XCTAssertEqual(solution!.description, TestData16.hard1.solutionString)
    }
    
    func testHasUniqueSolution() {
        var hasUniqueSolution = false
        self.measure {
            var result = true
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                for _ in 0..<50 {
                    result = result && TestData16.hard1.board.numberOfSolutions(using: &rng) == .one
                }
            }
            hasUniqueSolution = result
        }
        XCTAssertTrue(hasUniqueSolution)
    }

    func testPerfRandomFullyFilledBoard() {
        var board = SudokuBoard16.empty
        self.measure {
            var rng = WyRand(seed: 42)
            for _ in 0..<50 {
                board = SudokuBoard.randomFullyFilledBoard(using: &rng)
            }
        }
        // Generation is deterministic for a fixed seed; the exact board depends on
        // how many random values the solver consumes, so compare against a rerun.
        var expectedBoard = SudokuBoard16.empty
        var rng = WyRand(seed: 42)
        for _ in 0..<50 {
            expectedBoard = SudokuBoard.randomFullyFilledBoard(using: &rng)
        }
        XCTAssertEqual(board, expectedBoard)
        XCTAssertTrue(board.hasUniqueSolution)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 256)
    }

    func testPerfRandomStartingBoard() {
        var board = SudokuBoard16.empty
        self.measure {
            var rng = WyRand(seed: 42)
            for _ in 0..<5 {
                board = SudokuBoard.randomStartingBoard(rng: &rng)
            }
        }
        XCTAssertEqual(board.numberOfSolutions(), .one)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((70...120).contains(board.clues))
    }

    func testPerfRandomStartingBoardParallel() {
        var board = SudokuBoard16.empty
        self.measure {
            var rng = WyRand(seed: 42)
            for _ in 0..<5 {
                board = SudokuBoard16.randomFullyFilledBoard(using: &rng).minimizingCluesParallel(using: &rng)
            }
        }
        XCTAssertEqual(board.numberOfSolutions(), .one)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((70...120).contains(board.clues))
    }

}
