/// The total number of guess nodes the solver consumes finding the first solution
/// for each seed. Deterministic for fixed seeds: unlike wall-clock time, node
/// counts are unaffected by machine state, and unlike a single seed's timing they
/// average out guess-path luck across the seed list.
func totalFirstSolutionNodes<T: SudokuTypeProtocol>(solving puzzel: Puzzel<T>, seeds: [UInt64]) -> Int {
    var total = 0
    for seed in seeds {
        let rng = WyRand(seed: seed)
        guard var solver = SudokuSolver(eliminating: puzzel.board, rng: rng) else { continue }
        _ = solver.solve(transformation: Normal.self, maxSolutions: 1)
        total += Int.max - solver.nodesRemaining
    }
    return total
}
