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
        XCTAssertEqual(i, .index(SudokuCell16(solved: 0)))
        i = cell.index(after: i)
        XCTAssertEqual(i, .index(SudokuCell16(solved: 1)))
        i = cell.index(after: i)
        XCTAssertEqual(i, .index(SudokuCell16(solved: 2)))

        let expectedIndicies1: [SudokuCell16.Index] = (0..<16).map { .index(SudokuCell16(solved: $0)) }
        XCTAssertEqual(Array(cell.indices), expectedIndicies1)
        XCTAssertEqual(Array(cell), (0...15).map { SudokuCell16(solved: $0) })
        
        // Leave [0, 5, 8, 14]
        for i in [1, 2, 3, 4, 6, 7, 9, 10, 11, 12, 13, 15] {
            try! _ = cell.remove(SudokuCell16(solved: i))
        }
        
        XCTAssertEqual(cell.endIndex, .end)
        
        i = cell.startIndex
        XCTAssertEqual(i, .index(SudokuCell16(solved: 0)))
        i = cell.index(after: i)
        XCTAssertEqual(i, .index(SudokuCell16(solved: 5)))
        i = cell.index(after: i)
        XCTAssertEqual(i, .index(SudokuCell16(solved: 8)))
        i = cell.index(after: i)
        XCTAssertEqual(i, .index(SudokuCell16(solved: 14)))
        i = cell.index(after: i)
        XCTAssertEqual(i, cell.endIndex)
        
        let expectedIndicies2: [SudokuCell16.Index] = [0, 5, 8, 14].map { .index(SudokuCell16(solved: $0)) }
        XCTAssertEqual(Array(cell.indices), expectedIndicies2)
        XCTAssertEqual(Array(cell), [0, 5, 8, 14].map { SudokuCell16(solved: $0) })
        
    }

}
