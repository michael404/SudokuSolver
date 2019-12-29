import XCTest

class SudokuCellTests: XCTestCase {

    func testCell() {
        
        var cell = SudokuCell(solved: 9)
        XCTAssertEqual(cell.count, 1)
        XCTAssertTrue(cell.isSolved)
        XCTAssertEqual(cell.solvedValue, cell)
        XCTAssertEqual(cell.description, "9")
        XCTAssertEqual(cell.debugDescription, "9")
        for i in 1...8 {
            XCTAssertFalse(cell.contains(SudokuCell(solved: i)))
        }
        XCTAssertTrue(cell.contains(SudokuCell(solved: 9)))
        XCTAssertEqual(try? cell.remove(SudokuCell(solved: 1)), false)
        XCTAssertEqual(try? cell.remove(SudokuCell(solved: 9)), nil)
        
        cell = SudokuCell.allTrue
        XCTAssertEqual(cell.count, 9)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        for i in 1...9 {
            XCTAssertTrue(cell.contains(SudokuCell(solved: i)))
        }
        
        XCTAssertEqual(try? cell.remove(SudokuCell(solved: 1)), true)
        XCTAssertEqual(cell.count, 8)
        XCTAssertFalse(cell.isSolved)
        XCTAssertNil(cell.solvedValue)
        XCTAssertEqual(cell.description, " ")
        XCTAssertEqual(cell.debugDescription, ".")
        XCTAssertFalse(cell.contains(SudokuCell(solved: 1)))
         for i in 2...9 {
             XCTAssertTrue(cell.contains(SudokuCell(solved: i)))
         }
        XCTAssertEqual(try? cell.remove(SudokuCell(solved: 1)), false)
        
    }
    
    func testCellCollection() {
        var cell = SudokuCell.allTrue
        XCTAssertEqual(cell.endIndex, 1 << 10)
        
        var i = cell.startIndex
        XCTAssertEqual(i, 1)
        i = cell.index(after: i)
        XCTAssertEqual(i, 1 << 1)
        i = cell.index(after: i)
        XCTAssertEqual(i, 1 << 2)

        XCTAssertEqual(Array(cell.indices), (1...9).map { 1 << ($0 - 1) } )
        XCTAssertEqual(Array(cell), (1...9).map { SudokuCell(solved: $0) })
        
        for i in [1, 3, 4, 6, 7, 9] {
            try! _ = cell.remove(SudokuCell(solved: i))
        }
        
        XCTAssertEqual(cell.endIndex, 1 << 10)
        
        i = cell.startIndex
        XCTAssertEqual(i, 1 << 1)
        i = cell.index(after: i)
        XCTAssertEqual(i, 1 << 4)
        i = cell.index(after: i)
        XCTAssertEqual(i, 1 << 7)
        i = cell.index(after: i)
        XCTAssertEqual(i, cell.endIndex)
        
        XCTAssertEqual(Array(cell.indices), [2, 5, 8].map { 1 << ($0 - 1) } )
        XCTAssertEqual(Array(cell), [2, 5, 8].map { SudokuCell(solved: $0) })
        
    }

}
