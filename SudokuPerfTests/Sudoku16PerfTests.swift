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
    
}
