import XCTest

class Sudoku36PerfTests: XCTestCase {

    private static let solverSeeds: [UInt64] = [36, 37, 38]

    // Uses the harder 627-clue puzzle: first-solution search stays affordable on it
    // (~8s per iteration) while exercising much deeper backtracking.
    func testSudokuSolverEndToEnd() {

        var solution: SudokuBoard36?

        self.measure {
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                solution = TestData36.evil1.board.findFirstSolution(using: &rng)
            }
        }

        XCTAssertTrue(solution!.isFullyFilled)
        XCTAssertEqual(solution!.description, TestData36.evil1.solutionString)
    }

    // Stays on the 666-clue puzzle: proving uniqueness of the 627-clue one takes
    // 4-5M+ solver nodes per seed, which would put this test at ~16 minutes.
    func testHasUniqueSolution() {
        var hasUniqueSolution = false
        self.measure {
            var result = true
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                result = result && TestData36.puzzel1.board.numberOfSolutions(using: &rng) == .one
            }
            hasUniqueSolution = result
        }
        XCTAssertTrue(hasUniqueSolution)
    }

}
