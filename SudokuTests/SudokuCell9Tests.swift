import XCTest

class SudokuCell9Tests: XCTestCase {

    func testCell() {
        
        var cell = SudokuCell9("9")
        XCTAssertEqual(cell.count, 1)
        XCTAssertTrue(cell.isSolved)
        XCTAssertEqual(cell.solvedValue, cell)
        XCTAssertEqual(cell.description, "9")
        XCTAssertEqual(cell.debugDescription, "9")
        for i in 1...8 {
            XCTAssertFalse(cell.contains(SudokuCell9(String(i))))
        }
        XCTAssertTrue(cell.contains(SudokuCell9("9")))
        XCTAssertEqual(try? cell.remove(SudokuCell9("1")), false)
        XCTAssertEqual(try? cell.remove(SudokuCell9("9")), nil)
        
        cell = SudokuCell9.allTrue
        XCTAssertEqual(cell.count, 9)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        for i in 1...9 {
            XCTAssertTrue(cell.contains(SudokuCell9(String(i))))
        }
        
        XCTAssertEqual(try? cell.remove(SudokuCell9("1")), true)
        XCTAssertEqual(cell.count, 8)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        XCTAssertFalse(cell.contains(SudokuCell9("1")))
        for i in 2...9 {
             XCTAssertTrue(cell.contains(SudokuCell9(String(i))))
         }
        XCTAssertEqual(try? cell.remove(SudokuCell9("1")), false)
        
    }
    
    func testCellSequence() {
        var cell = SudokuCell9.allTrue
        
        var i = cell.makeIterator()
        XCTAssertEqual(i.next(), SudokuCell9("1"))
        XCTAssertEqual(i.next(), SudokuCell9("2"))
        XCTAssertEqual(i.next(), SudokuCell9("3"))

        XCTAssertEqual(Array(cell), (1...9).map { SudokuCell9(String($0)) })
        
        // Leave [2, 5, 8]
        for i in [1, 3, 4, 6, 7, 9] {
            XCTAssertNoThrow(try cell.remove(SudokuCell9(String(i))))
        }
        
        i = cell.makeIterator()
        XCTAssertEqual(i.next(), SudokuCell9("2"))
        XCTAssertEqual(i.next(), SudokuCell9("5"))
        XCTAssertEqual(i.next(), SudokuCell9("8"))
        XCTAssertNil(i.next())
        
        XCTAssertEqual(Array(cell), [2, 5, 8].map { SudokuCell9(String($0)) })
        XCTAssertEqual(cell.reversed(), [8, 5, 2].map { SudokuCell9(String($0)) })
        
    }

}
