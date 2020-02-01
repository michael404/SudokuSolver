import XCTest

class SudokuCell9Tests: XCTestCase {

    func testCell() {
        
        var cell = SudokuCell9(solved: 9)
        XCTAssertEqual(cell.count, 1)
        XCTAssertTrue(cell.isSolved)
        XCTAssertEqual(cell.solvedValue, cell)
        XCTAssertEqual(cell.description, "9")
        XCTAssertEqual(cell.debugDescription, "9")
        for i in 1...8 {
            XCTAssertFalse(cell.contains(SudokuCell9(solved: i)))
        }
        XCTAssertTrue(cell.contains(SudokuCell9(solved: 9)))
        XCTAssertEqual(try? cell.remove(SudokuCell9(solved: 1)), false)
        XCTAssertEqual(try? cell.remove(SudokuCell9(solved: 9)), nil)
        
        cell = SudokuCell9.allTrue
        XCTAssertEqual(cell.count, 9)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        for i in 1...9 {
            XCTAssertTrue(cell.contains(SudokuCell9(solved: i)))
        }
        
        XCTAssertEqual(try? cell.remove(SudokuCell9(solved: 1)), true)
        XCTAssertEqual(cell.count, 8)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        XCTAssertFalse(cell.contains(SudokuCell9(solved: 1)))
         for i in 2...9 {
             XCTAssertTrue(cell.contains(SudokuCell9(solved: i)))
         }
        XCTAssertEqual(try? cell.remove(SudokuCell9(solved: 1)), false)
        
    }
    
    func testCellCollection() {
        var cell = SudokuCell9.allTrue
        XCTAssertEqual(cell.endIndex.storage, 1 << 10)
        
        var i = cell.startIndex
        XCTAssertEqual(i, SudokuCell9(solved: 1))
        i = cell.index(after: i)
        XCTAssertEqual(i, SudokuCell9(solved: 2))
        i = cell.index(after: i)
        XCTAssertEqual(i, SudokuCell9(solved: 3))

        XCTAssertEqual(Array(cell.indices), (1...9).map { SudokuCell9(solved: $0) } )
        XCTAssertEqual(Array(cell), (1...9).map { SudokuCell9(solved: $0) })
        
        // Leave [2, 5, 8]
        for i in [1, 3, 4, 6, 7, 9] {
            try! _ = cell.remove(SudokuCell9(solved: i))
        }
        
        XCTAssertEqual(cell.endIndex.storage, 1 << 10)
        
        i = cell.startIndex
        XCTAssertEqual(i, SudokuCell9(solved: 2))
        i = cell.index(after: i)
        XCTAssertEqual(i, SudokuCell9(solved: 5))
        i = cell.index(after: i)
        XCTAssertEqual(i, SudokuCell9(solved: 8))
        i = cell.index(after: i)
        XCTAssertEqual(i, cell.endIndex)
        
        XCTAssertEqual(Array(cell.indices), [2, 5, 8].map { SudokuCell9(solved: $0) } )
        XCTAssertEqual(Array(cell), [2, 5, 8].map { SudokuCell9(solved: $0) })
        
    }

}
