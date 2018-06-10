public enum SudokuSolverError: Error {
    case unsolvable
    case tooManySolutions
}

internal struct SudokuCoordinate {
    
    let index: Int
    let row: Int
    let column: Int
    let block: Int
    
    init(_ index: Int) {
        self.index = index
        self.row = index / 9
        self.column = index % 9
        self.block = (self.row / 3) * 3 + (self.column / 3)
    }
    
}


public typealias RNG = RandomNumberGenerator

// Adapted from https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlRandom.swift
struct Xoroshiro: RNG {
    
    typealias State = (UInt64, UInt64)
    
    var state: State
    
    /// Initializes the Xoroshiro PRNG with a seed from Random.default
    init() {
        var random = Random.default
        self.init(seed: (random.next(), random.next()))
    }
    
    init(seed: State) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        let (l, k0, k1, k2): (UInt64, UInt64, UInt64, UInt64) = (64, 55, 14, 36)
        let result = state.0 &+ state.1
        let x = state.0 ^ state.1
        state.0 = ((state.0 << k0) | (state.0 >> (l - k0))) ^ x ^ (x << k1)
        state.1 = (x << k2) | (x >> (l - k2))
        return result
    }
}
