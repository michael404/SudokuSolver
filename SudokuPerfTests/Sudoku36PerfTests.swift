import XCTest

class Sudoku36PerfTests: XCTestCase {

    private static let solverSeeds: [UInt64] = [36, 37, 38]

    func testSudokuSolverEndToEnd() {

        var solution: SudokuBoard36?

        self.measure {
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                for _ in 0..<10 {
                    solution = TestData36.puzzel1.board.findFirstSolution(using: &rng)
                }
            }
        }

        XCTAssertTrue(solution!.isFullyFilled)
        XCTAssertEqual(solution!.description, TestData36.puzzel1.solutionString)
    }

    func testHasUniqueSolution() {
        var hasUniqueSolution = false
        self.measure {
            var result = true
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                for _ in 0..<10 {
                    result = result && TestData36.puzzel1.board.numberOfSolutions(using: &rng) == .one
                }
            }
            hasUniqueSolution = result
        }
        XCTAssertTrue(hasUniqueSolution)
    }

}
