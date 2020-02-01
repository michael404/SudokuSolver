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
        XCTAssertEqual(cell.endIndex, .end)
        
        var i = cell.startIndex
        XCTAssertEqual(i, .inRange(0b1111111111111111))
        i = cell.index(after: i)
        XCTAssertEqual(i, .inRange(0b1111111111111110))
        i = cell.index(after: i)
        XCTAssertEqual(i, .inRange(0b1111111111111100))
        
        XCTAssertEqual(cell.index(after: .inRange(0b1000000000000000)), .end)

        XCTAssertEqual(Array(cell), (0...15).map { SudokuCell16(solved: $0) })

        XCTAssertEqual(Array(cell.reversed()),
                       [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])

        // Leave [0, 5, 8, 14]
        for i in [1, 2, 3, 4, 6, 7, 9, 10, 11, 12, 13, 15] {
            try! _ = cell.remove(SudokuCell16(solved: i))
        }

        XCTAssertEqual(cell.endIndex, .end)

        i = cell.startIndex
        XCTAssertEqual(i, .inRange(0b0100000100100001))
        i = cell.index(after: i)
        XCTAssertEqual(i, .inRange(0b0100000100100000))
        i = cell.index(after: i)
        XCTAssertEqual(i, .inRange(0b0100000100000000))
        i = cell.index(after: i)
        XCTAssertEqual(i, .inRange(0b0100000000000000))
        i = cell.index(after: i)
        XCTAssertEqual(i, cell.endIndex)

        let expectedIndicies2: [SudokuCell16.Index] = [0b0100000100100001, 0b0100000100100000, 0b0100000100000000, 0b0100000000000000].map { .inRange($0) }
        XCTAssertEqual(Array(cell.indices), expectedIndicies2)
        XCTAssertEqual(Array(cell), [0, 5, 8, 14].map { SudokuCell16(solved: $0) })

        XCTAssertEqual(Array(cell.reversed()), [14, 8, 5, 0])
    }

}
