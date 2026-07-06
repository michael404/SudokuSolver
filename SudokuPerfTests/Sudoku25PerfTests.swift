import XCTest

class Sudoku25PerfTests: XCTestCase {

    private static let solverSeeds: [UInt64] = [25]

    func testSudokuSolverEndToEnd() {
        
        var solution: SudokuBoard25?
        
        self.measure {
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                solution = TestData25.puzzel1.board.findFirstSolution(using: &rng)
            }
        }
        
        XCTAssertTrue(solution!.isFullyFilled)
        XCTAssertEqual(solution!.description, TestData25.puzzel1.solutionString)
    }
    
    func testHasUniqueSolution() {
        var hasUniqueSolution = false
        self.measure {
            var result = true
            for seed in Self.solverSeeds {
                var rng = WyRand(seed: seed)
                result = result && TestData25.puzzel1.board.numberOfSolutions(using: &rng) == .one
            }
            hasUniqueSolution = result
        }
        XCTAssertTrue(hasUniqueSolution)
    }

}
