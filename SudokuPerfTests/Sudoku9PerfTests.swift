import XCTest

class Sudoku9PerfTests: XCTestCase {

    private static let solverSeeds: [UInt64] = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
    
    func testPerfSuite() {
        var solutions = Array(repeating: SudokuBoard9.empty, count: TestData9.perfTestSuite.count)
        self.measure {
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                for (index, puzzel) in TestData9.perfTestSuite.enumerated() {
                    solutions[index] = puzzel.board.findFirstSolution(using: &rng)!
                }
            }
        }
        for (solvedBoard, puzzel) in zip(solutions, TestData9.perfTestSuite) {
            XCTAssertEqual(solvedBoard, puzzel.solution)
        }
    }
    
    func testHasUniqueSolution() {
        var hasUniqueSolutions = false
        self.measure {
            var result = true
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                for puzzel in TestData9.perfTestSuite {
                    result = result && puzzel.board.numberOfSolutions(using: &rng) == .one
                }
            }
            hasUniqueSolutions = result
        }
        XCTAssertTrue(hasUniqueSolutions)
    }
    
    func testPerfRandomFullyFilledBoard() {
        var board = SudokuBoard9.empty
        self.measure {
            var rng = WyRand(seed: 42)
            for _ in 0..<50 {
                board = SudokuBoard.randomFullyFilledBoard(using: &rng)
            }
        }
        // The exact board depends on how many random values the solver consumes,
        // so instead of pinning a specific board, check that generation is
        // deterministic for a fixed seed.
        var expectedBoard = SudokuBoard9.empty
        var rng = WyRand(seed: 42)
        for _ in 0..<50 {
            expectedBoard = SudokuBoard.randomFullyFilledBoard(using: &rng)
        }
        XCTAssertEqual(board, expectedBoard)
        XCTAssertTrue(board.hasUniqueSolution)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
    }
    
    func testPerfRandomStartingBoard() {
        var board = SudokuBoard9.empty
        self.measure {
            var rng = WyRand(seed: 42)
            for _ in 0..<50 {
                board = SudokuBoard.randomStartingBoard(rng: &rng)
            }
        }
        XCTAssertEqual(board.numberOfSolutions(), .one)
        XCTAssertTrue(board.hasUniqueSolution)
        XCTAssertFalse(board.isFullyFilled)
        XCTAssertTrue((17...40).contains(board.clues))
    }
}
