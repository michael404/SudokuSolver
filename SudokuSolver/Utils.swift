import Foundation

public enum SudokuSolverError: Error {
    
    case unsolvable
    case tooManySolutions
    
}

public typealias RNG = RandomNumberGenerator

/// A linear congruential PRNG.
struct LCRNG: RNG {
    private var state: UInt64
    
    init(seed: Int) {
        state = UInt64(truncatingIfNeeded: seed)
        for _ in 0..<10 { _ = next() }
    }
    
    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}
