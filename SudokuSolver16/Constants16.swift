enum Constants16 {
        
    /// The 39  indicies that need to be checked when changing an index.
    /// (15 in the same row, 15 in the same column and then 9 remaining in the box)
    /// Laid out as a countinous array of 349indexes. Use the helper
    /// method to access the values.
    static let indiciesAffectedByIndex: [[Int]] = {
        (0...255).map { index in
            var indicies = Set<Int>()
            Self._indiciesInSameRowInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameColumnInclusive(as: index).forEach { indicies.insert($0) }
            Self._indiciesInSameBoxInclusive[index].forEach { indicies.insert($0) }
            //Remove self
            indicies.remove(index)
            //TODO: Consider if sorting is needed for deterministic tests here
            return Array(indicies).sorted()
        }
    }()
    
    // INCLUSIVE
    
    private static func _indiciesInSameRowInclusive(as index: Int) -> CountableRange<Int> {
        let start = (index / 16) * 16
        let end = start + 16
        return start..<end
    }
    
    private static func _indiciesInSameColumnInclusive(as index: Int) -> StrideThrough<Int> {
        stride(from: index % 16, through: 255, by: 16)
    }
    
    private static let _indiciesInSameBoxInclusive: [[Int]] = {
        (0...255).map { index in
            let row = index / 16
            let column = index % 16
            let startIndexOfBlock = (row / 4) * 64 + (column / 4) * 4
            return [0,1,2,3,16,17,18,19,32,33,34,35,48,49,50,51].map { startIndexOfBlock + $0 }
        }
    }()
    
    // EXCLUSIVE
    
    private static func _makeExclusive<S: Sequence>(_ input: (Int) -> S) -> [[Int]] where S.Element == Int {
        (0...255).map { index1 in input(index1).filter { index2 in index1 != index2 } }
    }
    
    static let indiciesInSameRowExclusive: [[Int]] = {
        Self._makeExclusive(Self._indiciesInSameRowInclusive(as:))
    }()
    
    static let indiciesInSameColumnExclusive: [[Int]] = {
        Self._makeExclusive(Self._indiciesInSameColumnInclusive(as:))
    }()
    
    static let indiciesInSameBoxExclusive: [[Int]] = {
        Self._makeExclusive { Self._indiciesInSameBoxInclusive[$0] }
    }()
    
    // ALL IN X
    
    static let allIndiciesInRow: [[Int]] = {
        (0...15).map { row in (0...15).map { offset in row * 16 + offset } }
    }()

    static let allIndiciesInColumn: [[Int]] = {
        (0...15).map { offset in stride(from: 0, through: 255, by: 16).map { start in start + offset } }
    }()
       
    static let allIndiciesInBox: [[Int]] = {
        let offsets = stride(from: 0, to: 64, by: 16).flatMap { $0..<($0 + 4) }
        let starts = offsets.map { $0 * 4 }
        return starts.map { start in offsets.map { offset in start + offset } }
    }()
    
}

