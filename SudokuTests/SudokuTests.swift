import XCTest

class SudokuTests: XCTestCase {
    
    func testSudokuSolverIntegration() {
        XCTAssertFalse(TestData.board1.isFullyFilled)
        XCTAssertTrue(TestData.board1.isValid)
        
        // Default solving method
        do {
            let solution = try! TestData.board1.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData.expectedSolution1)
        }
        
        // "From Start" solving method
        do {
            let solution = try! TestData.board1.findFirstSolution(method: .fromStart)
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData.expectedSolution1)
        }
    }
    
    func testInitFromString() {
        let board = SudokuBoard(TestData.board1String)
        XCTAssertEqual(board, TestData.board1)
        XCTAssertEqual(board.debugDescription, TestData.board1String)
    }
    
    func testIsValid() {
        XCTAssertTrue(TestData.board1.isValid)
        
        var board1NonValid = TestData.board1
        board1NonValid[0, 0] = 9
        XCTAssertFalse(board1NonValid.isValid)
        
        board1NonValid = TestData.board1
        board1NonValid[8, 6] = 5
        XCTAssertFalse(board1NonValid.isValid)
        
        board1NonValid = TestData.board1
        board1NonValid[6, 7] = 1
        XCTAssertFalse(board1NonValid.isValid)
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData.invalidBoard.isValid)
        XCTAssertThrowsError(try TestData.invalidBoard.findFirstSolution())
        XCTAssertThrowsError(try TestData.invalidBoard.findFirstSolution(method: .fromRowWithMostFilledValues))
    
    }
    
    func testFindAllSolutions() {
        do {
            let solutions = try! TestData.board1.findAllSolutions()
            XCTAssertEqual(solutions.count, 1)
            XCTAssertEqual(solutions[0].description, TestData.expectedSolution1)
        }
        
        do {
            // Too many solutions both with default and non-default maxSolutions
            XCTAssertThrowsError(try TestData.emptyBoard.findAllSolutions())
            XCTAssertThrowsError(try TestData.emptyBoard.findAllSolutions(maxSolutions: 50))
        }
        
        do {
            let solutions = try! TestData.multipleSolutionsBoard.findAllSolutions()
            XCTAssertEqual(solutions.count, 9)
            for solution in solutions {
                XCTAssertTrue(solution.isValid)
                XCTAssertTrue(solution.isFullyFilled)
            }
        }
    }
    
    func testTooManySolutions() {
        
        //Should throw
        XCTAssertThrowsError(try TestData.multipleSolutionsBoard.findAllSolutions(maxSolutions: 3))
        
        // Should only find 1 solution
        do {
            let solution = try! TestData.board1.findAllSolutions(maxSolutions: 1)
            XCTAssertEqual(solution.count, 1)
            XCTAssertTrue(solution[0].isValid)
            XCTAssertTrue(solution[0].isFullyFilled)
            XCTAssertEqual(solution[0].description, TestData.expectedSolution1)
        }
    }
    
    func testRandomFullyFilledBoard() {
        let board = SudokuBoard.randomFullyFilledBoard()
        XCTAssertTrue(board.isValid)
        XCTAssertTrue(board.isFullyFilled)
        XCTAssertEqual(board.clues, 81)
        
        // Two random boards should (usually) not be equal
        XCTAssertNotEqual(board, SudokuBoard.randomFullyFilledBoard())
    }
    
    func testFilledCells() {
        XCTAssertEqual(TestData.board1.clues, 27)
        XCTAssertEqual(TestData.board2.clues, 21)
        XCTAssertEqual(TestData.emptyBoard.clues, 0)
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
