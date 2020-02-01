import XCTest

class SudokuCell16Tests: XCTestCase {

    func testCell() {
        
        var cell = SudokuCell16(solved: 15)
        XCTAssertEqual(cell.count, 1)
        XCTAssertTrue(cell.isSolved)
        XCTAssertEqual(cell.solvedValue, cell)
        XCTAssertEqual(cell.description, "F")
        XCTAssertEqual(cell.debugDescription, "F")
        for i in 0...14 {
            XCTAssertFalse(cell.contains(SudokuCell16(solved: i)))
        }
        XCTAssertTrue(cell.contains(SudokuCell16(solved: 15)))
        XCTAssertEqual(try? cell.remove(SudokuCell16(solved: 1)), false)
        XCTAssertEqual(try? cell.remove(SudokuCell16(solved: 15)), nil)
        
        cell = SudokuCell16.allTrue
        XCTAssertEqual(cell.count, 16)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        for i in 1...15 {
            XCTAssertTrue(cell.contains(SudokuCell16(solved: i)))
        }
        
        XCTAssertEqual(try? cell.remove(SudokuCell16(solved: 1)), true)
        XCTAssertEqual(cell.count, 15)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        XCTAssertFalse(cell.contains(SudokuCell16(solved: 1)))
         for i in 2...15 {
             XCTAssertTrue(cell.contains(SudokuCell16(solved: i)))
         }
        XCTAssertEqual(try? cell.remove(SudokuCell16(solved: 1)), false)
        
    }
    
    func testCellCollection() {
        var cell = SudokuCell16.allTrue
        
        var i = cell.makeIterator()
        XCTAssertEqual(i.next(), SudokuCell16(solved: 0))
        XCTAssertEqual(i.next(), SudokuCell16(solved: 1))
        XCTAssertEqual(i.next(), SudokuCell16(solved: 2))
        
        XCTAssertEqual(Array(cell), (0...15).map { SudokuCell16(solved: $0) })

        XCTAssertEqual(Array(cell.reversed()),
                       [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])

        // Leave [0, 5, 8, 14]
        for i in [1, 2, 3, 4, 6, 7, 9, 10, 11, 12, 13, 15] {
            try! _ = cell.remove(SudokuCell16(solved: i))
        }

        i = cell.makeIterator()
        XCTAssertEqual(i.next(), SudokuCell16(solved: 0))
        XCTAssertEqual(i.next(), SudokuCell16(solved: 5))
        XCTAssertEqual(i.next(), SudokuCell16(solved: 8))
        XCTAssertEqual(i.next(), SudokuCell16(solved: 14))
        XCTAssertNil(i.next())


        XCTAssertEqual(Array(cell), [0, 5, 8, 14].map { SudokuCell16(solved: $0) })

        XCTAssertEqual(Array(cell.reversed()), [14, 8, 5, 0])
    }

}
