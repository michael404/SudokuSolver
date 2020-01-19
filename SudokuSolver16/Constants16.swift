enum Constants16 {

    static func indiciesAffected(by index: Int) -> [Int] {
        return Self._indiciesAffectedByIndex[index]
    }
    
    static func indiciesInSameRow(as index: Int) -> ArraySlice<Int> {
        let start = index * 45
        let end = start + 15
        return Self._indiciesInSameUnitAsIndex[start..<end]
    }
    
    static func indiciesInSameColumn(as index: Int) -> ArraySlice<Int> {
        let start = index * 45 + 15
        let end = start + 15
        return Self._indiciesInSameUnitAsIndex[start..<end]
    }
    
    static func indiciesInSameBox(as index: Int) -> ArraySlice<Int> {
        let start = index * 45 + 30
        let end = start + 15
        return Self._indiciesInSameUnitAsIndex[start..<end]
    }
    
    static func allIndiciesInRow(number: Int) -> ArraySlice<Int> {
        let start = number * 16
        let end = start + 16
        return Self._allIndiciesInRow[start..<end]
    }
    
    static func allIndiciesInColumn(number: Int) -> ArraySlice<Int> {
        let start = number * 16
        let end = start + 16
        return Self._allIndiciesInColumn[start..<end]
    }
    
    static func allIndiciesInBox(number: Int) -> ArraySlice<Int> {
        let start = number * 16
        let end = start + 16
        return Self._allIndiciesInBox[start..<end]
    }
    
}

private extension Constants16 {
    
    /// The 39  indicies that need to be checked when changing an index.
    /// (15 in the same row, 15 in the same column and then 9 remaining in the box)
    /// Laid out as a countinous array of 349indexes. Use the helper
    /// method to access the values.
    static let _indiciesAffectedByIndex: [[Int]] = {
        var result: [[Int]] = []
        result.reserveCapacity(256)
        for index in 0...255 {
            var indicies = Set<Int>()
            Self._indiciesInSameRow(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameColumn(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameBox(as: index).forEach { indicies.insert($0) }
            //Remove self
            indicies.remove(index)
            //TODO: Consider if sorting is needed for deterministic tests here
            result.append(Array(indicies).sorted())
        }
        return result
    }()
    
    static let _indiciesInSameUnitAsIndex: [Int] = {
        var result = [Int]()
        result.reserveCapacity(45 * 256)
        for i in 0...255 {
            result.append(contentsOf: Self._indiciesInSameRow(as: i).filter { $0 != i })
            result.append(contentsOf: Self._indiciesInSameColumn(as: i).filter { $0 != i })
            result.append(contentsOf: Self._indiciesInSameBox(as: i).filter { $0 != i })
        }
        assert(result.count == 45 * 256)
        return result
    }()
    
    static func _indiciesInSameRow(as index: Int) -> CountableRange<Int> {
        let start = (index / 16) * 16
        let end = start + 16
        return start..<end
    }
    
    static func _indiciesInSameColumn(as index: Int) -> StrideTo<Int> {
        let start = index % 16
        return stride(from: start, to: 256, by: 16)
    }
    
    static func _indiciesInSameBox(as index: Int) -> [Int] {
        let row = index / 16
        let column = index % 16
        var startIndexOfBlock: Int
        switch row {
        case 0...3: startIndexOfBlock = 0
        case 4...7: startIndexOfBlock = 16 * 4
        case 8...11: startIndexOfBlock = 16 * 8
        case 12...15: startIndexOfBlock = 16 * 12
        default: preconditionFailure()
        }
        switch column {
        case 4...7: startIndexOfBlock += 4
        case 8...11: startIndexOfBlock += 8
        case 12...15: startIndexOfBlock += 12
        default: break
        }
        return [0,1,2,3,16,17,18,19,32,33,34,35,48,49,50,51].map { startIndexOfBlock + $0 }
    }
    
    static let _allIndiciesInRow: [Int] = Array(0...255)

    static let _allIndiciesInColumn: [Int] = {
        var result: [Int] = []
        result.reserveCapacity(256)
        for firstRow in (0...15) {
            for i in stride(from: firstRow, through: 255, by: 16) {
                result.append(i)
            }
        }
        assert(result.count == 256)
        return result
    }()
       
    static let _allIndiciesInBox: [Int] = {
        let rowOffsets = [0, 1, 2, 3, 16, 17, 18, 19, 32, 33, 34, 35, 48, 49, 50, 51]
        let rowStarts = [0, 4, 8, 12, 64, 68, 72, 76, 128, 132, 136, 140, 192, 196, 200, 204]
        var result: [Int] = []
        result.reserveCapacity(256)
        for rowStart in rowStarts {
            let row = rowOffsets.lazy.map {$0 + rowStart }
            result.append(contentsOf: row)
        }
        assert(result.count == 256)
        return result
    }()
    
}

