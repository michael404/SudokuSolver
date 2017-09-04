import XCTest

class SudokuTests: XCTestCase {
    
    let board1 = SudokuBoard([
        .empty, .s9,    .empty, .empty, .empty, .empty, .s5,    .empty, .empty,
        .empty, .empty, .s1,    .s8,    .s9,    .empty, .empty, .s2,    .s4,
        .empty, .empty, .empty, .empty, .empty, .empty, .s7,    .empty, .s9,
        
        .empty, .empty, .s4,    .empty, .s8,    .s2,    .empty, .empty, .empty,
        .s8,    .empty, .empty, .empty, .s6,    .empty, .empty, .empty, .s3,
        .empty, .empty, .empty,  .s3,   .s5,    .empty, .s2,    .empty, .empty,
        
        .s5,    .empty, .s9,    .empty, .empty, .empty, .empty, .empty, .empty,
        .s7,    .s4,    .empty, .empty, .s2,    .s5,    .s1,    .empty, .empty,
        .empty, .empty, .s2,    .empty, .empty, .empty, .empty, .s7,    .empty
        ])
    
    let expectedSolution1 = """
            +-----+-----+-----+
            |4 9 7|2 3 6|5 8 1|
            |6 5 1|8 9 7|3 2 4|
            |2 8 3|5 4 1|7 6 9|
            +-----+-----+-----+
            |9 3 4|1 8 2|6 5 7|
            |8 2 5|7 6 9|4 1 3|
            |1 7 6|3 5 4|2 9 8|
            +-----+-----+-----+
            |5 1 9|6 7 3|8 4 2|
            |7 4 8|9 2 5|1 3 6|
            |3 6 2|4 1 8|9 7 5|
            +-----+-----+-----+
            
            """
    
    func testSudokuSolverIntegration() {
        XCTAssertFalse(board1.isFullyFilled())
        XCTAssertTrue(board1.isValid())
        let solver = try! SudokuSolver(board1)
        let solution = try! solver.solve()
        XCTAssertTrue(solution.isValid())
        XCTAssertTrue(solution.isFullyFilled())
        XCTAssertEqual(solution.description, expectedSolution1)
    }
    
    func testPerformanceExample() {
        
        var solution = SudokuBoard()
        
        self.measure {
            let solver = try! SudokuSolver(board1)
            solution = try! solver.solve()
        }
        
        XCTAssertEqual(solution.description, expectedSolution1)
        
    }
    
}
