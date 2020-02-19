enum SudokuSolverError: Error {
    case unsolvable
}

typealias RNG = RandomNumberGenerator

// Adapted from https://github.com/lemire/SwiftWyhash
struct WyRand: RNG {
        
    var state: UInt64
    
    /// Initializes the PRNG with a seed from the `SystemRandomNumberGenerator`
    init() {
        var rng = SystemRandomNumberGenerator()
        self.init(seed: rng.next())
    }

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func next() -> UInt64 {
        state &+= 0xa0761d6478bd642f
        let mul = state.multipliedFullWidth(by: state ^ 0xe7037ed1a0b428db)
        return mul.high ^ mul.low
    }
}

extension Collection {
    
    // Reservoir sampling
    func randomElement<R: RNG>(using rng: inout R, where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        var count = 0
        for element in self where predicate(element) && Int.random(in: 0...count, using: &rng) == 0 {
            result = element
            count += 1
        }
        return result
    }
    
}
