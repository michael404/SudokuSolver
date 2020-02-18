import XCTest

class SudokuSolver9Tests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {
        XCTAssertFalse(TestData9.hard1.board.isFullyFilled)
        XCTAssertTrue(TestData9.hard1.board.isValid)
        
        do {
            let solution = TestData9.hard1.board.findFirstSolution()!
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData9.hard1.solutionString)
        }
        
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData9.invalid.isValid)
        XCTAssertNil(TestData9.invalid.findFirstSolution())
    }
    
    func testFullyFilled() {
        let filledBoard = TestData9.filled
        XCTAssertEqual(filledBoard.clues, 81)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(filledBoard.findFirstSolution(), filledBoard)
        
    }
    
    func testFindAllSolutions() {
        do {
            let solutions =
                SudokuBoard9("....3...174..........5.4...4.38.5.2...79...6.......8575...1.6..6..4.721..1...3.9.")
                    .findAllSolutions()
            let expectedSolutions: Set<SudokuBoard9> = [
                SudokuBoard9("926738541745192386381564972463875129857921463192346857574219638639487215218653794"),
                SudokuBoard9("926738541745192386381564972463875129857921463192346857578219634639457218214683795"),
                SudokuBoard9("926738541745192386381564972463875129857921463192346857578219634639487215214653798"),
                SudokuBoard9("986732541745169382321584976463875129857921463192346857579218634638497215214653798")
            ]
            XCTAssertEqual(Set(solutions), expectedSolutions)
        }
        do {
            let solutions = TestData9.hard1.board.findAllSolutions()
            XCTAssertEqual(solutions, [TestData9.hard1.solution])
        }
        do {
            let solutions = TestData9.invalid.findAllSolutions()
            XCTAssertEqual(solutions, [])
        }
        do {
            let solutions = TestData9.manySolutions.board.findAllSolutions()
            XCTAssertEqual(Set(solutions), Set(TestData9.manySolutions.solutions))
        }
    }
    
    func testNumberOfSolutions() {
        XCTAssertEqual(TestData9.hard1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData9.hard1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData9.multipleSolutions.numberOfSolutions(), .multiple)
        XCTAssertEqual(TestData9.invalid.numberOfSolutions(), .none)
        XCTAssertEqual(
            SudokuBoard9("....3...174..........5.4...4.38.5.2...79...6.......8575...1.6..6..4.721..1...3.9.")
                .numberOfSolutions(),
            .multiple)
        XCTAssertEqual(
            SudokuBoard9("63.8..142.........5..4.239...4.8..6.....6..2..6.7..435.5....98.4...9.....2.......")
                .numberOfSolutions(),
            .multiple)
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
            XCTAssertTrue(allTrue.contains(SudokuCell9(String(i))))
        }
        
        var someFalse = allTrue
        XCTAssertTrue(try someFalse.remove(SudokuCell("1")))
        XCTAssertTrue(try someFalse.remove(SudokuCell("7")))
        XCTAssertFalse(try someFalse.remove(SudokuCell("7")))
        XCTAssertEqual(someFalse.count, 7)
        XCTAssertFalse(someFalse.isSolved)
        XCTAssertNil(someFalse.solvedValue)
        XCTAssertFalse(someFalse.contains(SudokuCell("1")))
        XCTAssertFalse(someFalse.contains(SudokuCell("7")))
        XCTAssertEqual(Array(someFalse), [2, 3, 4, 5, 6, 8, 9].map(String.init).map(SudokuCell.init))
        
        for i in ["2", "3", "4", "5", "6", "8"] {
            XCTAssertTrue(try someFalse.remove(SudokuCell(String(i))), "Expected true when removing value \(i)")
        }
        XCTAssertEqual(someFalse.count, 1)
        XCTAssertTrue(someFalse.isSolved)
        XCTAssertEqual(someFalse.solvedValue, SudokuCell("9"))
        XCTAssertEqual(Array(someFalse), [SudokuCell("9")])
        
        let oneValue = SudokuCell9("6")
        XCTAssertEqual(oneValue.count, 1)
        XCTAssertTrue(oneValue.isSolved)
        XCTAssertEqual(oneValue.solvedValue, SudokuCell("6"))
        XCTAssertEqual(Array(oneValue), [SudokuCell("6")])
    }
        
}
