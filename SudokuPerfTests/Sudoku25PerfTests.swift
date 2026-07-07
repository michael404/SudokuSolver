import XCTest

class Sudoku25PerfTests: XCTestCase {

    /// First-solution searches are heavily guess-path dependent, so the end-to-end
    /// test averages over many seeds; exhaustive uniqueness proofs are much less
    /// path-sensitive and keep a short seed list to bound the suite's runtime.
    private static let endToEndSeeds: [UInt64] = [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36]
    private static let uniquenessSeeds: [UInt64] = [25, 26, 27]

    func testSudokuSolverEndToEnd() {

        var solution: SudokuBoard25?

        self.measure {
            for seed in Self.endToEndSeeds {
                var rng = WyRand(seed: seed)
                solution = TestData25.puzzel1.board.findFirstSolution(using: &rng)
            }
        }

        // Node counts are exactly reproducible for fixed seeds, immune to machine
        // noise and guess-path luck, so log them as the stable comparison metric.
        print("Sudoku25 end-to-end nodes across \(Self.endToEndSeeds.count) seeds: "
            + "\(totalFirstSolutionNodes(solving: TestData25.puzzel1, seeds: Self.endToEndSeeds))")

        XCTAssertTrue(solution!.isFullyFilled)
        XCTAssertEqual(solution!.description, TestData25.puzzel1.solutionString)
    }

    func testHasUniqueSolution() {
        var hasUniqueSolution = false
        self.measure {
            var result = true
            for seed in Self.uniquenessSeeds {
                var rng = WyRand(seed: seed)
                result = result && TestData25.puzzel1.board.numberOfSolutions(using: &rng) == .one
            }
            hasUniqueSolution = result
        }
        XCTAssertTrue(hasUniqueSolution)
    }

}
