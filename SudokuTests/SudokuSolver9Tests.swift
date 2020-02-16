import XCTest

class SudokuSolver9Tests: XCTestCase {
    
    func testSudokuSolverEndToEnd() {
        XCTAssertFalse(TestData9.hard1.board.isFullyFilled)
        XCTAssertTrue(TestData9.hard1.board.isValid)
        
        do {
            let solution = try! TestData9.hard1.board.findFirstSolution()
            XCTAssertTrue(solution.isValid)
            XCTAssertTrue(solution.isFullyFilled)
            XCTAssertEqual(solution.description, TestData9.hard1.solutionString)
        }
        
    }
    
    func testFailingBoard() {
        XCTAssertFalse(TestData9.invalid.isValid)
        XCTAssertThrowsError(try TestData9.invalid.findFirstSolution())
    }
    
    func testFullyFilled() {
        let filledBoard = TestData9.filled
        XCTAssertEqual(filledBoard.clues, 81)
        XCTAssertTrue(filledBoard.isFullyFilled)
        // A filled board should return itself as a solution
        XCTAssertEqual(try! filledBoard.findFirstSolution(), filledBoard)
        
    }
    
    func testFindAllSolutions() {
        do {
            let solutions =  SudokuBoard9("....3...174..........5.4...4.38.5.2...79...6.......8575...1.6..6..4.721..1...3.9.").findAllSolutions()
            let expectedSolutions: Set<SudokuBoard9> = [
                SudokuBoard9("926738541745192386381564972463875129857921463192346857574219638639487215218653794"),
                SudokuBoard9("926738541745192386381564972463875129857921463192346857578219634639457218214683795"),
                SudokuBoard9("926738541745192386381564972463875129857921463192346857578219634639487215214653798"),
                SudokuBoard9("986732541745169382321584976463875129857921463192346857579218634638497215214653798"),
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
            let solutions = try! SudokuBoard9("....3...174..........5.4...4.38...2...7....6.......8575...1.6..6..4.721..1...3.9.").findAllSolutions()
            let expectedSolutions: Set<SudokuBoard9> = [
                SudokuBoard9("896732541745169382321584976453876129187925463962341857579218634638497215214653798"),
                SudokuBoard9("896732541745961382321584976453876129987125463162349857579218634638497215214653798"),
                SudokuBoard9("926738541745129386381564972463875129857291463192346857574912638639487215218653794"),
                SudokuBoard9("926738541745129386381564972463875129857291463192346857578912634639457218214683795"),
                SudokuBoard9("926738541745129386381564972463875129857291463192346857578912634639487215214653798"),
                SudokuBoard9("926738541745169382381524976463875129857291463192346857574912638639487215218653794"),
                SudokuBoard9("926738541745169382381524976463875129857291463192346857578912634639457218214683795"),
                SudokuBoard9("926738541745169382381524976463875129857291463192346857578912634639487215214653798"),
                SudokuBoard9("926738541745192386381564972463875129857921463192346857574219638639487215218653794"),
                SudokuBoard9("926738541745192386381564972463875129857921463192346857578219634639457218214683795"),
                SudokuBoard9("926738541745192386381564972463875129857921463192346857578219634639487215214653798"),
                SudokuBoard9("926738541745291386381564972453876129897125463162349857574912638639487215218653794"),
                SudokuBoard9("926738541745291386381564972453876129897125463162349857578912634639457218214683795"),
                SudokuBoard9("926738541745291386381564972453876129897125463162349857578912634639487215214653798"),
                SudokuBoard9("926738541745291386381564972463875129857129463192346857574912638639487215218653794"),
                SudokuBoard9("926738541745291386381564972463875129857129463192346857578912634639457218214683795"),
                SudokuBoard9("926738541745291386381564972463875129857129463192346857578912634639487215214653798"),
                SudokuBoard9("926738541745921386381564972463875129857192463192346857574219638639487215218653794"),
                SudokuBoard9("926738541745921386381564972463875129857192463192346857578219634639457218214683795"),
                SudokuBoard9("926738541745921386381564972463875129857192463192346857578219634639487215214653798"),
                SudokuBoard9("926738541745961382381524976463875129857192463192346857574219638639487215218653794"),
                SudokuBoard9("926738541745961382381524976463875129857192463192346857578219634639457218214683795"),
                SudokuBoard9("926738541745961382381524976463875129857192463192346857578219634639487215214653798"),
                SudokuBoard9("962738541745291386381564972453876129897125463126349857574912638639487215218653794"),
                SudokuBoard9("962738541745291386381564972453876129897125463126349857578912634639457218214683795"),
                SudokuBoard9("962738541745291386381564972453876129897125463126349857578912634639487215214653798"),
                SudokuBoard9("962738541745921386381564972453876129827195463196342857574219638639487215218653794"),
                SudokuBoard9("962738541745921386381564972453876129827195463196342857578219634639457218214683795"),
                SudokuBoard9("962738541745921386381564972453876129827195463196342857578219634639487215214653798"),
                SudokuBoard9("962738541745961382381524976453876129827195463196342857574219638639487215218653794"),
                SudokuBoard9("962738541745961382381524976453876129827195463196342857578219634639457218214683795"),
                SudokuBoard9("962738541745961382381524976453876129827195463196342857578219634639487215214653798"),
                SudokuBoard9("965732481742981536381564972453876129897125364126349857579218643638497215214653798"),
                SudokuBoard9("965732481748169532321584976453876129187295364296341857572918643639457218814623795"),
                SudokuBoard9("968732541745169382321584976453876129187295463296341857572918634639457218814623795"),
                SudokuBoard9("986732541745169382321584976463875129857921463192346857579218634638497215214653798"),
                SudokuBoard9("986732541745961382321584976453876129897125463162349857579218634638497215214653798"),
                SudokuBoard9("986732541745961382321584976463875129857129463192346857579218634638497215214653798"),
            ]
            XCTAssertEqual(Set(solutions), expectedSolutions)
        }
    }
    
    func testNumberOfSolutions() {
        XCTAssertEqual(TestData9.hard1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData9.hard1.board.numberOfSolutions(), .one)
        XCTAssertEqual(TestData9.multipleSolutions.numberOfSolutions(), .multiple)
        XCTAssertEqual(TestData9.invalid.numberOfSolutions(), .none)
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
        XCTAssertEqual(Array(someFalse), [2,3,4,5,6,8,9].map(String.init).map(SudokuCell.init))
        
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

