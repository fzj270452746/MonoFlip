import Foundation

// Date-seeded procedural puzzle, unique per calendar day.
// Uses a linear-congruential PRNG so puzzles are reproducible without storage.

enum DailyPuzzle {
    static var todayID: Int {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: Date())
        // Encode date as an integer so we get one stable id per day
        return (c.year ?? 2024) * 10000 + (c.month ?? 1) * 100 + (c.day ?? 1)
    }

    static func spec(for date: Date = Date()) -> StageSpec {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        let seed = UInt64((c.year ?? 2024) * 10000 + (c.month ?? 1) * 100 + (c.day ?? 1))
        var rng = LCG(seed: seed)

        let size = 5
        // Generate a random fully-lit board, then apply random flips to create the puzzle
        var grid: [[Bool]] = Array(repeating: Array(repeating: true, count: size), count: size)
        let flipCount = Int(rng.next() % 8) + 4   // 4…11 flips
        var solution: [(Int,Int)] = []
        for _ in 0..<flipCount {
            let r = Int(rng.next() % UInt64(size))
            let c = Int(rng.next() % UInt64(size))
            solution.append((r, c))
            // Apply cross flip manually
            for (dr, dc) in [(0,0),(-1,0),(1,0),(0,-1),(0,1)] {
                let nr = r + dr; let nc = c + dc
                guard nr >= 0, nr < size, nc >= 0, nc < size else { continue }
                grid[nr][nc].toggle()
            }
        }
        let par = max(solution.count - 2, solution.count)
        let df = DateFormatter(); df.dateFormat = "MMM d"
        let title = df.string(from: date)

        return StageSpec(id: -1, chapter: 0, size: size, initial: grid,
                         kinds: nil, goal: .allWhite,
                         parMoves: par, timeLimitSec: 0, title: title)
    }
}

// Minimal LCG for reproducible deterministic sequences
private struct LCG {
    var state: UInt64
    init(seed: UInt64) { state = seed ^ 0x123456789ABCDEF }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state >> 33
    }
}
