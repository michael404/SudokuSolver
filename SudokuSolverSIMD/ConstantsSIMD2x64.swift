extension SudokuBoardSIMD2x64 {

    static func makeMasks(indicies: [[Int]]) -> [Mask] {
        var result = indicies.indices.map { _ in Mask(repeating: true) }

        for number in indicies.indices {
            for i in indicies[number] {
                result[number][i] = false
                
            }
        }
        return result
    }

    static let rowIndiciesS1 = [Array(0..<9), Array(9..<18), Array(18..<27), Array(27..<36), Array(36..<45), Array(45..<54)]
    static let rowMasksS1 = makeMasks(indicies: rowIndiciesS1)

    static let rowIndiciesS2 = [Array(54..<63), Array(63..<72), Array(72..<81)]
        .map { $0.map { $0 - 54 } } //TODO: Precalculate this
    static let rowMasksS2 = makeMasks(indicies: rowIndiciesS2)

    static let boxIndiciesS1 = [
        [ 0,  1,  2,  9, 10, 11, 18, 19, 20],
        [ 3,  4,  5, 12, 13, 14, 21, 22, 23],
        [ 6,  7,  8, 15, 16, 17, 24, 25, 26],
        [27, 28, 29, 36, 37, 38, 45, 46, 47],
        [30, 31, 32, 39, 40, 41, 48, 49, 50],
        [33, 34, 35, 42, 43, 44, 51, 52, 53]]
    static let boxMasksS1 = makeMasks(indicies: boxIndiciesS1)

    static let boxIndiciesS2 = [
        [54, 55, 56, 63, 64, 65, 72, 73, 74],
        [57, 58, 59, 66, 67, 68, 75, 76, 77],
        [60, 61, 62, 69, 70, 71, 78, 79, 80]]
        .map { $0.map { $0 - 54 } } //TODO: Precalculate this
    static let boxMasksS2 = makeMasks(indicies: boxIndiciesS2)

    static let colIndiciesS1 = [
        [0,  9, 18, 27, 36, 45],
        [1, 10, 19, 28, 37, 46],
        [2, 11, 20, 29, 38, 47],
        [3, 12, 21, 30, 39, 48],
        [4, 13, 22, 31, 40, 49],
        [5, 14, 23, 32, 41, 50],
        [6, 15, 24, 33, 42, 51],
        [7, 16, 25, 34, 43, 52],
        [8, 17, 26, 35, 44, 53]]
    static let colMasksS1 = makeMasks(indicies: colIndiciesS1)

    static let colIndiciesS2 = [
        [54, 63, 72],
        [55, 64, 73],
        [56, 65, 74],
        [57, 66, 75],
        [58, 67, 76],
        [59, 68, 77],
        [60, 69, 78],
        [61, 70, 79],
        [62, 71, 80]]
        .map { $0.map { $0 - 54 } }  //TODO: Precalculate this

    static let colMasksS2 = makeMasks(indicies: colIndiciesS2)
    
    static let inverseRepeated = (0..<512).map { Storage(repeating: ~$0) }

}
