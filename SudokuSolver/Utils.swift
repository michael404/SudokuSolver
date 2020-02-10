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

extension FixedWidthInteger where Self: SignedInteger {
    
    var highestSetBit: Self {
        assert(self != 0, "Cannot return a highest set bit on an empty bit set")
        var result = self | self >> 1
        var i: Self = 1
        //Iterate over 1, 2, 4, 8, etc. unil you reach the last bit, which for a signed
        //integer will be Self.min
        while i != Self.min {
            result |= result >> i
            i <<= 1
        }
        result += 1
        return result >> 1
    }
    
}
