import XCTest

class Sudoku36PerfTests: XCTestCase {

    /// First-solution searches are heavily guess-path dependent, so the end-to-end
    /// test averages over many seeds; exhaustive uniqueness proofs are much less
    /// path-sensitive and keep a short seed list to bound the suite's runtime.
    private static let endToEndSeeds: [UInt64] = [36, 37, 38, 39, 40, 41, 42, 43]
    private static let uniquenessSeeds: [UInt64] = [36, 37, 38]

    // Uses the harder 627-clue puzzle: first-solution search stays affordable on it
    // while exercising much deeper backtracking.
    func testSudokuSolverEndToEnd() {

        var solution: SudokuBoard36?

        self.measure {
            for seed in Self.endToEndSeeds {
                var rng = WyRand(seed: seed)
                solution = TestData36.evil1.board.findFirstSolution(using: &rng)
            }
        }

        // Node counts are exactly reproducible for fixed seeds, immune to machine
        // noise and guess-path luck, so log them as the stable comparison metric.
        print("Sudoku36 end-to-end nodes across \(Self.endToEndSeeds.count) seeds: "
            + "\(totalFirstSolutionNodes(solving: TestData36.evil1, seeds: Self.endToEndSeeds))")

        XCTAssertTrue(solution!.isFullyFilled)
        XCTAssertEqual(solution!.description, TestData36.evil1.solutionString)
    }

    // Stays on the 666-clue puzzle: proving uniqueness of the 627-clue one takes
    // many millions of solver nodes per seed.
    func testHasUniqueSolution() {
        var hasUniqueSolution = false
        self.measure {
            var result = true
            for seed in Self.uniquenessSeeds {
                var rng = WyRand(seed: seed)
                result = result && TestData36.puzzel1.board.numberOfSolutions(using: &rng) == .one
            }
            hasUniqueSolution = result
        }
        XCTAssertTrue(hasUniqueSolution)
    }

}
