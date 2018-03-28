import XCTest

class SudokuTestsAlt: XCTestCase {
    
    func testSudokuSolverIntegration() {
        XCTAssertFalse(TestData.board1.isFullyFilled)
        XCTAssertTrue(TestData.board1.isValid)
        
        do {
            let solution = try! TestData.board1.findFirstSolutionAlt()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData.expectedSolution1)
        }
        
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData.invalidBoard.isValid)
        XCTAssertThrowsError(try TestData.invalidBoard.findFirstSolutionAlt())
    }
    
    /*func testFindAllSolutions() {
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
    }*/
    
    /*func testManySolutions() {
        
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
        
    }*/
    
    /*func testNumberOfSolutions() {
        XCTAssertEqual(TestData.board1.numberOfSolutions(), .one)
        XCTAssertEqual(TestData.board2.numberOfSolutions(), .one)
        XCTAssertEqual(TestData.multipleSolutionsBoard.numberOfSolutions(), .multiple)
        XCTAssertEqual(TestData.invalidBoard.numberOfSolutions(), .none)
    }*/
    
//    func testRandomFullyFilledBoard() {
//        let board = SudokuBoard.randomFullyFilledBoard()
//        XCTAssertTrue(board.isValid)
//        XCTAssertTrue(board.isFullyFilled)
//        XCTAssertEqual(board.clues, 81)
//        
//        
//        // Two random filled boards should (usually) not be equal
//        XCTAssertNotEqual(board, SudokuBoard.randomFullyFilledBoard())
//    }
    
//    func testRandomStartingBoard() {
//        do {
//            let board = SudokuBoard.randomStartingBoard()
//            XCTAssertTrue(board.isValid)
//            XCTAssertFalse(board.isFullyFilled)
//        }
//
//        do {
//            let board = SudokuBoard.randomStartingBoard()
//            XCTAssertTrue(board.isValid)
//            XCTAssertFalse(board.isFullyFilled)
//            XCTAssert(board.clues <= 40) // Maximum that should be possible
//            XCTAssert(board.clues >= 17) // inimum that should be possible
//        }
//
//        // Two random starting boards should (usually) not be equal
//        XCTAssertNotEqual(SudokuBoard.randomStartingBoard(), SudokuBoard.randomStartingBoard())
//    }
    
    func testOneToNine() {
        let allTrue = OneToNineSet(allTrue: ())
        XCTAssertEqual(allTrue.count, 9)
        XCTAssertNil(allTrue.solvedValue)
        for i in 1...9 {
            XCTAssertTrue(allTrue.contains(i))
        }
        
        var someFalse = allTrue
        XCTAssertTrue(someFalse.remove(1))
        XCTAssertTrue(someFalse.remove(7))
        XCTAssertFalse(someFalse.remove(7))
        XCTAssertEqual(someFalse.count, 7)
        XCTAssertFalse(someFalse.isSolved)
        XCTAssertNil(someFalse.solvedValue)
        XCTAssertFalse(someFalse.contains(1))
        XCTAssertFalse(someFalse.contains(7))
        XCTAssertEqual(Array(someFalse), [2,3,4,5,6,8,9])
        
        XCTAssertTrue(someFalse.remove(2))
        XCTAssertTrue(someFalse.remove(3))
        XCTAssertTrue(someFalse.remove(4))
        XCTAssertTrue(someFalse.remove(5))
        XCTAssertTrue(someFalse.remove(6))
        XCTAssertTrue(someFalse.remove(8))
        XCTAssertEqual(someFalse.count, 1)
        XCTAssertTrue(someFalse.isSolved)
        XCTAssertEqual(someFalse.solvedValue, 9)
        XCTAssertEqual(Array(someFalse), [9])
        
        let oneValue = OneToNineSet(6)
        XCTAssertEqual(oneValue.count, 1)
        XCTAssertTrue(oneValue.isSolved)
        XCTAssertEqual(oneValue.solvedValue, 6)
        XCTAssertEqual(Array(oneValue), [6])
    }
    
    func testFixedArray81() {
        var array = FixedArray81(repeating: 1)
        XCTAssertEqual(array.count, 81)
        XCTAssertFalse(array.isEmpty)
        var i = 0
        for element in array {
            i += 1
            XCTAssertEqual(element, 1)
        }
        XCTAssertEqual(i, 81)
        XCTAssertEqual(array.reduce(0, +), 81)
        XCTAssertEqual(array[40], 1)
        
        array[10] = 0
        array[20] = 100
        XCTAssertEqual(array.count, 81)
        XCTAssertFalse(array.isEmpty)
        XCTAssertEqual(array.reduce(0, +), 179)
        XCTAssertEqual(array[10], 0)
        XCTAssertEqual(array[20], 100)
        XCTAssertEqual(array[40], 1)
    }
        
}

