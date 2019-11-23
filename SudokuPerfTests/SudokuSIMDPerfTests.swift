import XCTest

class SudokuSIMDPerfTests: XCTestCase {
    
    func testHard_2x64() {
        let board = SudokuBoardSIMD2x64(TestData.Hard1.board)
        var result = SudokuBoardSIMD2x64.empty
        self.measure {
            result = try! board.findFirstSolution()
        }
        let solution = SudokuBoardSIMD2x64(TestData.Hard1.solution)
        XCTAssertEqual(result, solution)
    }
    
    func testHard2_2x64() {
        let board = SudokuBoardSIMD2x64(TestData.Hard2.board)
        var result = SudokuBoardSIMD2x64.empty
        self.measure {
            result = try! board.findFirstSolution()
        }
        let solution = SudokuBoardSIMD2x64(TestData.Hard2.solution)
        XCTAssertEqual(result, solution)
    }
    
    func testHard_3x32() {
         let board = SudokuBoardSIMD3x32(TestData.Hard1.board)
         var result = SudokuBoardSIMD3x32.empty
         self.measure {
             result = try! board.findFirstSolution()
         }
         let solution = SudokuBoardSIMD3x32(TestData.Hard1.solution)
         XCTAssertEqual(result, solution)
     }
    
    func testHard2_3x32() {
         let board = SudokuBoardSIMD3x32(TestData.Hard2.board)
         var result = SudokuBoardSIMD3x32.empty
         self.measure {
             result = try! board.findFirstSolution()
         }
         let solution = SudokuBoardSIMD3x32(TestData.Hard2.solution)
         XCTAssertEqual(result, solution)
     }
        
    func test_64() {
        var update = SIMD64<UInt16>(511, 256, 511, 511, 511, 511, 16, 511, 511, 511, 511, 1, 128, 256, 511, 511, 2, 8, 511, 511, 511, 511, 511, 511, 64, 511, 256, 511, 511, 8, 511, 128, 2, 511, 511, 511, 128, 511, 511, 511, 32, 511, 511, 511, 4, 511, 511, 511, 4, 16, 511, 2, 511, 511, 511, 511, 511, 511, 511, 511, 511, 511, 511, 511)
        let masks = SudokuBoardSIMD2x64.rowMasksS1
        let indicies = SudokuBoardSIMD2x64.rowIndiciesS1
        let inverseRepeated = (0..<512).map { ~SIMD64<UInt16>(repeating: $0) }
        var fakeThrow = 0
        self.measure {
            for _ in 0..<10000 {
                for number in indicies.indices {
                    let original = update
                    let isSolvedMask = update.nonzeroBitCount .== 1
                    var solvedValuesFound: UInt16 = .zero
                    for i in indicies[number] where isSolvedMask[i] {
                        let solvedValue = original[i]
                        guard (solvedValue & solvedValuesFound) == .zero else { fakeThrow += 1; continue }
                        solvedValuesFound |= solvedValue
                        update &= inverseRepeated[Int(truncatingIfNeeded: solvedValue)]
                    }
                    update.replace(with: original, where: isSolvedMask)
                    update.replace(with: original, where: masks[number])
                }
            }
        }
        let expected = SIMD64<UInt16>(
            239, 256, 239, 239, 239, 239, 16, 239, 239, 116, 116, 1, 128, 256, 116, 116, 2, 8, 191, 191, 191, 191, 191, 191, 64, 191, 256, 373, 373, 8, 373, 128, 2, 373, 373, 373, 128, 347, 347, 347, 32, 347, 347, 347, 4, 489, 489, 489, 4, 16, 489, 2, 489, 489, 511, 511, 511, 511, 511, 511, 511, 511, 511, 511)
        XCTAssertEqual(fakeThrow, 0)
        XCTAssertEqual(update, expected)
    }
    
     func test_32() {
        func makeMasks_32(indicies: [[Int]]) -> [SIMDMask<SIMD32<UInt16.SIMDMaskScalar>>] {
            var result = indicies.indices.map { _ in SIMDMask<SIMD32<UInt16.SIMDMaskScalar>>(repeating: true) }
            for number in indicies.indices {
                for i in indicies[number] {
                    result[number][i] = false
                    
                }
            }
            return result
        }
        var update = SIMD32<UInt16>(
            511, 256, 511, 511, 511, 511, 16, 511, 511,
            511, 511, 1, 128, 256, 511, 511, 2, 8,
            511, 511, 511, 511, 511, 511, 64, 511, 256,
            511, 511, 511, 511, 511)
        let indicies = Array(SudokuBoardSIMD2x64.rowIndiciesS1[0..<3])
        let masks = makeMasks_32(indicies: indicies)
        var fakeThrow = 0
        self.measure {
            for _ in 0..<10000 {
                for number in indicies.indices {
                    let original = update
                    let isSolvedMask = update.nonzeroBitCount .== 1
                    var solvedValuesFound: UInt16 = .zero
                    for i in indicies[number] where isSolvedMask[i] {
                        let solvedValue = original[i]
                        guard (solvedValue & solvedValuesFound) == .zero else { fakeThrow += 1; continue }
                        solvedValuesFound |= solvedValue
                        update &= ~SIMD32<UInt16>(repeating: solvedValue)
                    }
                    update.replace(with: original, where: isSolvedMask)
                    update.replace(with: original, where: masks[number])
                }
            }
        }
        let expected = SIMD32<UInt16>(
            239, 256, 239, 239, 239, 239, 16, 239, 239,
            116, 116, 1, 128, 256, 116, 116, 2, 8,
            191, 191, 191, 191, 191, 191, 64, 191, 256,
            511, 511, 511, 511, 511)
        XCTAssertEqual(fakeThrow, 0)
        XCTAssertEqual(update, expected)
    }
    
     func test_16() {
        func makeMasks_16(indicies: [[Int]]) -> [SIMDMask<SIMD16<UInt16.SIMDMaskScalar>>] {
            var result = indicies.indices.map { _ in SIMDMask<SIMD16<UInt16.SIMDMaskScalar>>(repeating: true) }
            for number in indicies.indices {
                for i in indicies[number] {
                    result[number][i] = false
                    
                }
            }
            return result
        }
        var update = SIMD16<UInt16>(
            511, 256, 511, 511, 511, 511, 16, 511, 511,
            511, 511, 511, 511, 511, 511, 511)
        let indicies = Array(SudokuBoardSIMD2x64.rowIndiciesS1[0..<1])
        let masks = makeMasks_16(indicies: indicies)
        var fakeThrow = 0
        self.measure {
            for _ in 0..<10000 {
                for number in indicies.indices {
                    let original = update
                    let isSolvedMask = update.nonzeroBitCount .== 1
                    var solvedValuesFound: UInt16 = .zero
                    for i in indicies[number] where isSolvedMask[i] {
                        let solvedValue = original[i]
                        guard (solvedValue & solvedValuesFound) == .zero else { fakeThrow += 1; continue }
                        solvedValuesFound |= solvedValue
                        update &= ~SIMD16<UInt16>(repeating: solvedValue)
                    }
                    update.replace(with: original, where: isSolvedMask)
                    update.replace(with: original, where: masks[number])
                }
            }
        }
        let expected = SIMD16<UInt16>(
            239, 256, 239, 239, 239, 239, 16, 239, 239,
            511, 511, 511, 511, 511, 511, 511)
        XCTAssertEqual(fakeThrow, 0)
        XCTAssertEqual(update, expected)
    }
    
}


