extension SudokuBoardSIMD3x32 {

    static func makeMasks(indicies: [[Int]]) -> [Mask] {
        var result = indicies.indices.map { _ in Mask(repeating: true) }

        for number in indicies.indices {
            for i in indicies[number] {
                result[number][i] = false
                
            }
        }
        return result
    }

    static let rowIndicies = [Array(0..<9), Array(9..<18), Array(18..<27)]
    static let rowMasks = makeMasks(indicies: rowIndicies)


    static let boxIndicies = [
        [ 0,  1,  2,  9, 10, 11, 18, 19, 20],
        [ 3,  4,  5, 12, 13, 14, 21, 22, 23],
        [ 6,  7,  8, 15, 16, 17, 24, 25, 26]]
    static let boxMasks = makeMasks(indicies: boxIndicies)
    
    static let colIndicies = [
        [0,  9, 18],
        [1, 10, 19],
        [2, 11, 20],
        [3, 12, 21],
        [4, 13, 22],
        [5, 14, 23],
        [6, 15, 24],
        [7, 16, 25],
        [8, 17, 26]]
    static let colMasks = makeMasks(indicies: colIndicies)

}
