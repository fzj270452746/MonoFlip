import Foundation

// MARK: - Tile

enum TileKind: Int, Codable {
    case normal, locked, bomb
}

struct Tile: Equatable {
    var lit: Bool        // true = white
    var kind: TileKind
    var locked: Bool { kind == .locked }
}

// MARK: - Board

struct Board: Equatable {
    let rows: Int
    let cols: Int
    var tiles: [[Tile]]

    init(rows: Int, cols: Int, data: [[Bool]], kinds: [[TileKind]]? = nil) {
        self.rows = rows
        self.cols = cols
        self.tiles = (0..<rows).map { r in
            (0..<cols).map { c in
                Tile(lit: data[r][c], kind: kinds?[r][c] ?? .normal)
            }
        }
    }

    subscript(r: Int, c: Int) -> Tile {
        get { tiles[r][c] }
        set { tiles[r][c] = newValue }
    }

    var isAllLit: Bool  { tiles.allSatisfy { $0.allSatisfy { $0.lit } } }
    var isAllDark: Bool { tiles.allSatisfy { $0.allSatisfy { !$0.lit } } }
}

// MARK: - Mutation types

struct TileMutation {
    let row: Int
    let col: Int
    let fromLit: Bool
}

struct FlipResult {
    let mutations: [TileMutation]
    let board: Board
}

// MARK: - Engine

enum TileMutationEngine {
    static func cross(_ board: Board, row: Int, col: Int) -> FlipResult {
        var next = board
        var mutations: [TileMutation] = []
        var flipped = Set<Int>()   // index = r*cols+c, prevents double-flip

        func flip(_ r: Int, _ c: Int) {
            guard r >= 0, r < board.rows, c >= 0, c < board.cols else { return }
            guard !next[r,c].locked else { return }
            let idx = r * board.cols + c
            guard !flipped.contains(idx) else { return }
            flipped.insert(idx)
            let old = next[r,c].lit
            next.tiles[r][c].lit.toggle()
            mutations.append(.init(row: r, col: c, fromLit: old))
        }

        let targets = [(row,col),(row-1,col),(row+1,col),(row,col-1),(row,col+1)]
        for (r,c) in targets {
            guard r >= 0, r < board.rows, c >= 0, c < board.cols else { continue }
            guard !next[r,c].locked else { continue }
            if next[r,c].kind == .bomb {
                // bomb: expand to 3×3 instead of single cell
                for dr in -1...1 { for dc in -1...1 { flip(r+dr, c+dc) } }
            } else {
                flip(r, c)
            }
        }
        return FlipResult(mutations: mutations, board: next)
    }
}
