import XCTest

class SudokuCell16Tests: XCTestCase {

    func testCell() {
        
        var cell = SudokuCell16("F")
        XCTAssertEqual(cell.count, 1)
        XCTAssertTrue(cell.isSolved)
        XCTAssertEqual(cell.solvedValue, cell)
        XCTAssertEqual(cell.description, "F")
        XCTAssertEqual(cell.debugDescription, "F")
        for i in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E"] {
            XCTAssertFalse(cell.contains(SudokuCell16(i)))
        }
        XCTAssertTrue(cell.contains(SudokuCell16("F")))
        XCTAssertEqual(try? cell.remove(SudokuCell16("1")), false)
        XCTAssertEqual(try? cell.remove(SudokuCell16("F")), nil)
        
        cell = SudokuCell16.allTrue
        XCTAssertEqual(cell.count, 16)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        for i in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E"] {
            XCTAssertTrue(cell.contains(SudokuCell16(i)))
        }
        
        XCTAssertEqual(try? cell.remove(SudokuCell16("1")), true)
        XCTAssertEqual(cell.count, 15)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        XCTAssertFalse(cell.contains(SudokuCell16("1")))
         for i in ["2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E"] {
             XCTAssertTrue(cell.contains(SudokuCell16(i)))
         }
        XCTAssertEqual(try? cell.remove(SudokuCell16("1")), false)
        
    }
    
    func testCellCollection() {
        var cell = SudokuCell16.allTrue
        
        var i = cell.makeIterator()
        XCTAssertEqual(i.next(), SudokuCell16("0"))
        XCTAssertEqual(i.next(), SudokuCell16("1"))
        XCTAssertEqual(i.next(), SudokuCell16("2"))
        
        XCTAssertEqual(
            Array(cell),
            ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"].map(SudokuCell16.init))

        XCTAssertEqual(
            Array(cell.reversed()),
            ["F", "E", "D", "C", "B", "A", "9", "8", "7", "6", "5", "4", "3", "2", "1", "0"].map(SudokuCell16.init))

        // Leave [0, 5, 8, E]
        for i in ["1", "2", "3", "4", "6", "7", "9", "A", "B", "C", "D", "F"] {
            XCTAssertNoThrow(try cell.remove(SudokuCell16(i)))
        }

        i = cell.makeIterator()
        XCTAssertEqual(i.next(), SudokuCell16("0"))
        XCTAssertEqual(i.next(), SudokuCell16("5"))
        XCTAssertEqual(i.next(), SudokuCell16("8"))
        XCTAssertEqual(i.next(), SudokuCell16("E"))
        XCTAssertNil(i.next())

        XCTAssertEqual(Array(cell), ["0", "5", "8", "E"].map(SudokuCell16.init))

        XCTAssertEqual(Array(cell.reversed()), ["E", "8", "5", "0"].map(SudokuCell16.init))
    }

}
