enum SudokuSolverError: Error {
    case unsolvable
    case tooManySolutions
}

typealias RNG = RandomNumberGenerator

// Adapted from https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlRandom.swift
struct Xoroshiro: RNG {
    
    typealias State = (UInt64, UInt64)
    
    var state: State
    
    /// Initializes the Xoroshiro PRNG with a seed from the `SystemRandomNumberGenerator`
    init() {
        var rng = SystemRandomNumberGenerator()
        self.init(seed: (rng.next(), rng.next()))
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

protocol SudokuCellIteratorStorageProtocol: SignedInteger & BinaryInteger {
    var highestSetBit: Self { get }
}

extension Int8: SudokuCellIteratorStorageProtocol {
    
    var highestSetBit: Int8 {
        assert(self != 0)
        var result = self | self >> 1
        result |= result >> 2
        result |= result >> 4
        result += 1
        return result >> 1
    }
    
}

extension Int16: SudokuCellIteratorStorageProtocol {
    
    var highestSetBit: Int16 {
        assert(self != 0)
        var result = self | self >> 1
        result |= result >> 2
        result |= result >> 4
        result |= result >> 8
        result += 1
        return result >> 1
    }
    
}

extension Int32: SudokuCellIteratorStorageProtocol {
    
    var highestSetBit: Int32 {
        assert(self != 0)
        var result = self | self >> 1
        result |= result >> 2
        result |= result >> 4
        result |= result >> 8
        result |= result >> 16
        result += 1
        return result >> 1
    }
    
}
