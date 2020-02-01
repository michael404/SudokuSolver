import XCTest

class SudokuSolver9Tests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {
        XCTAssertFalse(TestData9.Hard1.board.isFullyFilled)
        XCTAssertTrue(TestData9.Hard1.board.isValid)
        
        do {
            let solution = try! TestData9.Hard1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData9.Hard1.solutionString)
        }
        
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData9.Invalid.board.isValid)
        XCTAssertThrowsError(try TestData9.Invalid.board.findFirstSolution())
    }
    
    func testFullyFilled() {
        let filledBoard = TestData9.Filled.board
        XCTAssertEqual(filledBoard.clues, 81)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolution(), filledBoard)
        
    }
    
    func testNumberOfSolutions() {
        XCTAssertEqual(TestData9.Hard1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData9.Hard2.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData9.MultipleSolutions.board.numberOfSolutions(), .multiple)
        XCTAssertEqual(TestData9.Invalid.board.numberOfSolutions(), .none)
        XCTAssertEqual(SudokuBoard9("....3...174..........5.4...4.38.5.2...79...6.......8575...1.6..6..4.721..1...3.9.").numberOfSolutions(), .multiple)
        XCTAssertEqual(SudokuBoard9("63.8..142.........5..4.239...4.8..6.....6..2..6.7..435.5....98.4...9.....2.......").numberOfSolutions(), .multiple)

    }
    
    func testRandomFullyFilledBoard() {
        do {
            let board = SudokuBoard9.randomFullyFilledBoard()
            XCTAssertEqual(board.numberOfSolutions(), .one)
            XCTAssertTrue(board.isValid)
            XCTAssertTrue(board.isFullyFilled)
        }
    }
    
    func testRandomStartingBoard() {
        
        // Standard RNG
        do {
            let board = SudokuBoard9.randomStartingBoard()
            XCTAssertEqual(board.numberOfSolutions(), .one)
            XCTAssertTrue(board.isValid)
            XCTAssertFalse(board.isFullyFilled)
            XCTAssertTrue((17...40).contains(board.clues))
        }
        
        // Custom PRNG
        do {
            var rng = Xoroshiro()
            let board = SudokuBoard9.randomStartingBoard(rng: &rng)
            XCTAssertEqual(board.numberOfSolutions(), .one)
            XCTAssertTrue(board.isValid)
            XCTAssertFalse(board.isFullyFilled)
            XCTAssertTrue((17...40).contains(board.clues))
        }
    }

    func testOneToNine() {
        let allTrue = SudokuCell9.allTrue
        XCTAssertEqual(allTrue.count, 9)
        XCTAssertNil(allTrue.solvedValue)
        for i in 1...9 {
            XCTAssertTrue(allTrue.contains(SudokuCell9(solved: i)))
        }
        
        var someFalse = allTrue
        XCTAssertTrue(try someFalse.remove(1))
        XCTAssertTrue(try someFalse.remove(7))
        XCTAssertFalse(try someFalse.remove(7))
        XCTAssertEqual(someFalse.count, 7)
        XCTAssertFalse(someFalse.isSolved)
        XCTAssertNil(someFalse.solvedValue)
        XCTAssertFalse(someFalse.contains(1))
        XCTAssertFalse(someFalse.contains(7))
        XCTAssertEqual(Array(someFalse), [2,3,4,5,6,8,9])
        
        XCTAssertTrue(try someFalse.remove(2))
        XCTAssertTrue(try someFalse.remove(3))
        XCTAssertTrue(try someFalse.remove(4))
        XCTAssertTrue(try someFalse.remove(5))
        XCTAssertTrue(try someFalse.remove(6))
        XCTAssertTrue(try someFalse.remove(8))
        XCTAssertEqual(someFalse.count, 1)
        XCTAssertTrue(someFalse.isSolved)
        XCTAssertEqual(someFalse.solvedValue, 9)
        XCTAssertEqual(Array(someFalse), [9])
        
        let oneValue = SudokuCell9(solved: 6)
        XCTAssertEqual(oneValue.count, 1)
        XCTAssertTrue(oneValue.isSolved)
        XCTAssertEqual(oneValue.solvedValue, 6)
        XCTAssertEqual(Array(oneValue), [6])
    }
        
}

