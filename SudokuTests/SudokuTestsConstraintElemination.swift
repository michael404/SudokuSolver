import XCTest

class SudokuSolverTestsConstraintElimination: XCTestCase {
    
    func testSudokuSolverEndToEnd() {
        XCTAssertFalse(TestData.Hard1.board.isFullyFilled)
        XCTAssertTrue(TestData.Hard1.board.isValid)
        
        do {
            let solution = try! TestData.Hard1.board.findFirstSolutionConstraintElimination()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData.Hard1.solutionString)
        }
        
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData.Invalid.board.isValid)
        XCTAssertThrowsError(try TestData.Invalid.board.findFirstSolutionConstraintElimination())
    }
    
    func testFullyFilled() {
        let filledBoard = TestData.Filled.board
        XCTAssertEqual(filledBoard.clues, 81)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolutionConstraintElimination(), filledBoard)
        
    }
    
    func testConvertionToSudokuBoard() {
        // Not fully filled
        do {
            let pvb = try! PossibleCellValuesBoard(TestData.Hard1.board)
            let sb = SudokuBoard(pvb)
            XCTAssertEqual(sb, TestData.Hard1.board)
        }
        
        // Fully filled
        do {
            let pvb = try! PossibleCellValuesBoard(TestData.Filled.board)
            let sb = SudokuBoard(pvb)
            XCTAssertEqual(sb, TestData.Filled.board)
        }
    }
    
    func testOneToNine() {
        let allTrue = PossibleCellValues.allTrue
        XCTAssertEqual(allTrue.count, 9)
        XCTAssertNil(allTrue.solvedValue)
        for i in 1...9 {
            XCTAssertTrue(allTrue.contains(PossibleCellValues(solved: i)))
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
        
        let oneValue = PossibleCellValues(solved: 6)
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

