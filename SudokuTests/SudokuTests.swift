import XCTest

class SudokuTests: XCTestCase {
    
    let board1 = SudokuBoard(
        0, 9, 0,   0, 0, 0,   5, 0, 0,
        0, 0, 1,   8, 9, 0,   0, 2, 4,
        0, 0, 0,   0, 0, 0,   7, 0, 9,
        
        0, 0, 4,   0, 8, 2,   0, 0, 0,
        8, 0, 0,   0, 6, 0,   0, 0, 3,
        0, 0, 0,   3, 5, 0,   2, 0, 0,
        
        5, 0, 9,   0, 0, 0,   0, 0, 0,
        7, 4, 0,   0, 2, 5,   1, 0, 0,
        0, 0, 2,   0, 0, 0,   0, 7, 0)
    
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
    
    func testIsValid() {
        XCTAssertTrue(board1.isValid())
        
        var board1NonValid = board1
        board1NonValid[0, 0] = 9
        XCTAssertFalse(board1NonValid.isValid())
        
        board1NonValid = board1
        board1NonValid[8, 6] = 5
        XCTAssertFalse(board1NonValid.isValid())
        
        board1NonValid = board1
        board1NonValid[6, 7] = 1
        XCTAssertFalse(board1NonValid.isValid())
        
        
    }
    
    func testPerformanceExample() {
        
        var solution = SudokuBoard()
        
        self.measure {
            let solver = try! SudokuSolver(board1)
            solution = try! solver.solve()
        }
        
        XCTAssertEqual(solution.description, expectedSolution1)
        
    }
    
    func testBitMask() {
        let a = SudokuValidator.Mask()
        for i in 0..<10 {
            for j in 0..<10 {
                XCTAssertFalse(a[i, j])
            }
        }
        var c = SudokuValidator.Mask()
        for i in 0...9 {
            c[0,i] = true
            XCTAssertTrue(c[0,i])
        }
        for i in 0...9 {
            XCTAssertFalse(c[1,i])
        }
        c[2,0] = true
        XCTAssertTrue(c[2,0])
        for i in 1...9 {
            XCTAssertFalse(c[2,i])
        }
        c[3,0] = true
        XCTAssertTrue(c[3,0])
        for i in 1...9 {
            XCTAssertFalse(c[3,i])
        }
        c[4,1] = true
        XCTAssertTrue(c[4,1])
        c[4,1] = false
        XCTAssertFalse(c[4,1])
        for i in 2...50 {
            XCTAssertFalse(c[4,i])
        }
    }
    
}
