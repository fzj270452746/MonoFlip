import Foundation

enum StageCatalog {
    static let all: [StageSpec] = (1...10).flatMap { chapterStages($0) }

    static func chapterStages(_ ch: Int) -> [StageSpec] {
        switch ch {
        case 1:  return chapter1
        case 2:  return chapter2
        case 3:  return chapter3
        case 4:  return chapter4
        case 5:  return chapter5
        case 6:  return chapter6
        case 7:  return chapter7
        case 8:  return chapter8
        case 9:  return chapter9
        case 10: return chapter10
        default: return []
        }
    }

    // MARK: Chapter 1 – Basics (3×3, no par)

    static let chapter1: [StageSpec] = [
        s(1,  ch:1, size:3, title:"One Touch",
          grid:[[false,false,false],[false,false,false],[false,false,false]],
          goal:.allWhite, par:0),
        s(2,  ch:1, size:3, title:"Corner Pair",
          grid:[[false,true,false],[true,false,true],[false,true,false]],
          goal:.allWhite, par:0),
        s(3,  ch:1, size:3, title:"Stripe",
          grid:[[false,false,false],[true,true,true],[false,false,false]],
          goal:.allWhite, par:0),
        s(4,  ch:1, size:3, title:"Invert",
          grid:[[true,true,true],[true,false,true],[true,true,true]],
          goal:.allWhite, par:0),
        s(5,  ch:1, size:3, title:"Diagonal",
          grid:[[false,true,false],[false,false,false],[false,true,false]],
          goal:.allWhite, par:0),
    ]

    // MARK: Chapter 2 – Move limits (5×5)

    static let chapter2: [StageSpec] = [
        s(6,  ch:2, size:5, title:"Economy",
          grid:b5(false), goal:.allWhite, par:5),
        s(7,  ch:2, size:5, title:"Checkers",
          grid:(0..<5).map{r in (0..<5).map{c in (r+c)%2==0}},
          goal:.allWhite, par:6),
        s(8,  ch:2, size:5, title:"Rings",
          grid:[[true,true,true,true,true],
                [true,false,false,false,true],
                [true,false,true,false,true],
                [true,false,false,false,true],
                [true,true,true,true,true]],
          goal:.allWhite, par:7),
        s(9,  ch:2, size:5, title:"Cross",
          grid:[[true,false,true,false,true],
                [false,false,false,false,false],
                [true,false,true,false,true],
                [false,false,false,false,false],
                [true,false,true,false,true]],
          goal:.allWhite, par:8),
        s(10, ch:2, size:5, title:"Spiral",
          grid:[[false,false,false,false,false],
                [false,true,true,true,false],
                [false,true,false,true,false],
                [false,true,true,false,false],
                [false,false,false,false,false]],
          goal:.allWhite, par:6),
    ]

    // MARK: Chapter 3 – Special tiles

    static let chapter3: [StageSpec] = [
        s(11, ch:3, size:5, title:"Fortress",
          grid:[[false,false,false,false,false],
                [false,true,true,true,false],
                [false,true,false,true,false],
                [false,true,true,true,false],
                [false,false,false,false,false]],
          kinds:lockedCenter5(), goal:.allWhite, par:0),
        s(12, ch:3, size:5, title:"Pillars",
          grid:[[false,true,false,true,false],
                [false,false,false,false,false],
                [false,true,false,true,false],
                [false,false,false,false,false],
                [false,true,false,true,false]],
          kinds:lockedCorners5(), goal:.allWhite, par:0),
        s(13, ch:3, size:5, title:"Moat",
          grid:[[true,true,true,true,true],
                [true,false,false,false,true],
                [true,false,false,false,true],
                [true,false,false,false,true],
                [true,true,true,true,true]],
          kinds:lockedRing5(), goal:.allWhite, par:0),
        s(14, ch:3, size:5, title:"Bomb Run",
          grid:b5(false),
          kinds:bombCenter5(), goal:.allWhite, par:3),
        s(15, ch:3, size:5, title:"Labyrinth",
          grid:[[false,true,false,true,false],
                [true,false,true,false,true],
                [false,true,false,true,false],
                [true,false,true,false,true],
                [false,true,false,true,false]],
          kinds:mixedKinds5(), goal:.allWhite, par:0),
    ]

    // MARK: Chapter 4 – 7×7 wide

    static let chapter4: [StageSpec] = [
        s(16, ch:4, size:7, title:"Void",
          grid:b7(false), goal:.allWhite, par:9),
        s(17, ch:4, size:7, title:"Maze",
          grid:[[false,true,false,false,false,true,false],
                [false,true,false,true,false,true,false],
                [false,false,false,true,false,false,false],
                [true,true,false,false,false,true,true],
                [false,false,false,true,false,false,false],
                [false,true,false,true,false,true,false],
                [false,true,false,false,false,true,false]],
          goal:.allWhite, par:10),
        s(18, ch:4, size:7, title:"Mirror",
          grid:[[true,false,false,true,false,false,true],
                [false,true,false,true,false,true,false],
                [false,false,true,true,true,false,false],
                [true,true,true,false,true,true,true],
                [false,false,true,true,true,false,false],
                [false,true,false,true,false,true,false],
                [true,false,false,true,false,false,true]],
          goal:.allWhite, par:8),
        s(19, ch:4, size:7, title:"Cascade",
          grid:[[false,false,false,false,false,false,false],
                [false,false,false,false,false,false,false],
                [true,true,true,true,true,true,true],
                [false,false,false,false,false,false,false],
                [true,true,true,true,true,true,true],
                [false,false,false,false,false,false,false],
                [false,false,false,false,false,false,false]],
          goal:.allWhite, par:11),
        s(20, ch:4, size:7, title:"Abyss",
          grid:[[true,true,false,true,false,true,true],
                [true,false,false,false,false,false,true],
                [false,false,true,false,true,false,false],
                [true,false,false,true,false,false,true],
                [false,false,true,false,true,false,false],
                [true,false,false,false,false,false,true],
                [true,true,false,true,false,true,true]],
          goal:.allBlack, par:10),
    ]

    // MARK: Chapter 5 – 9×9 Hell

    static let chapter5: [StageSpec] = [
        s(21, ch:5, size:9, title:"Entropy",
          grid:(0..<9).map{r in (0..<9).map{c in (r+c)%2==0}},
          goal:.allWhite, par:15),
        s(22, ch:5, size:9, title:"Pandora",
          grid:(0..<9).map{r in (0..<9).map{c in (r+c)%2==1}},
          goal:.allBlack, par:16),
        s(23, ch:5, size:9, title:"Singularity",
          grid:(0..<9).map{r in (0..<9).map{c in abs(r-4)+abs(c-4)>2}},
          goal:.allWhite, par:18),
        s(24, ch:5, size:9, title:"Collapse",
          grid:(0..<9).map{r in (0..<9).map{c in r<4||c<4}},
          goal:.allBlack, par:20),
        s(25, ch:5, size:9, title:"Mono",
          grid:[[true,false,true,false,true,false,true,false,true],
                [false,false,false,false,false,false,false,false,false],
                [true,false,true,false,true,false,true,false,true],
                [false,false,false,false,false,false,false,false,false],
                [true,false,true,false,false,false,true,false,true],
                [false,false,false,false,false,false,false,false,false],
                [true,false,true,false,true,false,true,false,true],
                [false,false,false,false,false,false,false,false,false],
                [true,false,true,false,true,false,true,false,true]],
          goal:.allWhite, par:0),
    ]

    // MARK: Chapter 6 – 5×5 with par + bombs

    static let chapter6: [StageSpec] = [
        s(26, ch:6, size:5, title:"Fission",
          grid:[[true,false,true,false,true],
                [false,true,false,true,false],
                [true,false,false,false,true],
                [false,true,false,true,false],
                [true,false,true,false,true]],
          kinds:bombsAt5([(1,1),(3,3)]), goal:.allWhite, par:5),
        s(27, ch:6, size:5, title:"Chain",
          grid:[[false,false,true,false,false],
                [false,true,false,true,false],
                [true,false,false,false,true],
                [false,true,false,true,false],
                [false,false,true,false,false]],
          kinds:bombsAt5([(0,2),(4,2)]), goal:.allWhite, par:4),
        s(28, ch:6, size:5, title:"Bunker",
          grid:[[true,true,true,true,true],
                [true,false,false,false,true],
                [true,false,true,false,true],
                [true,false,false,false,true],
                [true,true,true,true,true]],
          kinds:lockedRing5(), goal:.allWhite, par:4),
        s(29, ch:6, size:5, title:"Scatter",
          grid:b5(true),
          kinds:bombsAt5([(0,0),(0,4),(4,0),(4,4)]), goal:.allBlack, par:6),
        s(30, ch:6, size:5, title:"Reactor",
          grid:[[true,true,false,true,true],
                [true,false,false,false,true],
                [false,false,true,false,false],
                [true,false,false,false,true],
                [true,true,false,true,true]],
          kinds:bombsAt5([(2,2)]), goal:.allBlack, par:5),
    ]

    // MARK: Chapter 7 – 7×7 with locked + bombs

    static let chapter7: [StageSpec] = [
        s(31, ch:7, size:7, title:"Armory",
          grid:[[false,true,false,true,false,true,false],
                [true,false,false,false,false,false,true],
                [false,false,true,false,true,false,false],
                [true,false,false,false,false,false,true],
                [false,false,true,false,true,false,false],
                [true,false,false,false,false,false,true],
                [false,true,false,true,false,true,false]],
          kinds:lockedEdge7(), goal:.allWhite, par:10),
        s(32, ch:7, size:7, title:"Ordnance",
          grid:b7(false),
          kinds:bombGrid7(), goal:.allWhite, par:8),
        s(33, ch:7, size:7, title:"Bulwark",
          grid:[[true,true,true,true,true,true,true],
                [true,false,false,false,false,false,true],
                [true,false,true,true,true,false,true],
                [true,false,true,false,true,false,true],
                [true,false,true,true,true,false,true],
                [true,false,false,false,false,false,true],
                [true,true,true,true,true,true,true]],
          kinds:lockedOuterRing7(), goal:.allWhite, par:8),
        s(34, ch:7, size:7, title:"Deadlock",
          grid:(0..<7).map{r in (0..<7).map{c in (r+c)%2==0}},
          kinds:lockedCross7(), goal:.allBlack, par:12),
        s(35, ch:7, size:7, title:"Detonator",
          grid:[[false,false,false,true,false,false,false],
                [false,false,true,false,true,false,false],
                [false,true,false,false,false,true,false],
                [true,false,false,true,false,false,true],
                [false,true,false,false,false,true,false],
                [false,false,true,false,true,false,false],
                [false,false,false,true,false,false,false]],
          kinds:bombsAt7([(0,3),(3,0),(3,6),(6,3),(3,3)]), goal:.allWhite, par:6),
    ]

    // MARK: Chapter 8 – 9×9 with pattern goals

    static let chapter8: [StageSpec] = [
        s(36, ch:8, size:9, title:"Diamond",
          grid:(0..<9).map{r in (0..<9).map{c in abs(r-4)+abs(c-4)<=3}},
          goal:.allBlack, par:14),
        s(37, ch:8, size:9, title:"Lattice",
          grid:(0..<9).map{r in (0..<9).map{c in r%2==0 && c%2==0}},
          goal:.allWhite, par:18),
        s(38, ch:8, size:9, title:"Fortress",
          grid:(0..<9).map{r in (0..<9).map{c in r==0||r==8||c==0||c==8}},
          kinds:lockedOuterRing9(), goal:.allWhite, par:12),
        s(39, ch:8, size:9, title:"Whirlpool",
          grid:whirlpool9(),
          goal:.allBlack, par:20),
        s(40, ch:8, size:9, title:"Storm",
          grid:(0..<9).map{r in (0..<9).map{c in (r*c)%3==0}},
          kinds:bombsAt9([(2,2),(2,6),(6,2),(6,6)]),
          goal:.allWhite, par:16),
    ]

    // MARK: Chapter 9 – Mixed 7×7 hard

    static let chapter9: [StageSpec] = [
        s(41, ch:9, size:7, title:"Cipher",
          grid:[[true,false,true,false,true,false,true],
                [false,false,false,true,false,false,false],
                [true,false,true,false,true,false,true],
                [false,true,false,false,false,true,false],
                [true,false,true,false,true,false,true],
                [false,false,false,true,false,false,false],
                [true,false,true,false,true,false,true]],
          kinds:bombsAt7([(1,3),(3,1),(3,5),(5,3)]), goal:.allWhite, par:10),
        s(42, ch:9, size:7, title:"Fracture",
          grid:[[false,true,true,false,true,true,false],
                [true,false,false,true,false,false,true],
                [true,false,false,false,false,false,true],
                [false,true,false,true,false,true,false],
                [true,false,false,false,false,false,true],
                [true,false,false,true,false,false,true],
                [false,true,true,false,true,true,false]],
          kinds:lockedDiag7(), goal:.allWhite, par:12),
        s(43, ch:9, size:7, title:"Paradox",
          grid:b7(true),
          kinds:lockedHalf7(), goal:.allBlack, par:11),
        s(44, ch:9, size:7, title:"Ruin",
          grid:ruin7(), kinds:ruinKinds7(), goal:.allWhite, par:14),
        s(45, ch:9, size:7, title:"Eclipse",
          grid:(0..<7).map{r in (0..<7).map{c in abs(r-3)+abs(c-3)<=2}},
          kinds:bombsAt7([(0,0),(0,6),(6,0),(6,6)]), goal:.allBlack, par:9),
    ]

    // MARK: Chapter 10 – 9×9 Endgame

    static let chapter10: [StageSpec] = [
        s(46, ch:10, size:9, title:"Aether",
          grid:(0..<9).map{r in (0..<9).map{c in (r%3==1)||(c%3==1)}},
          goal:.allBlack, par:22),
        s(47, ch:10, size:9, title:"Void Core",
          grid:voidCore9(),
          kinds:bombsAt9([(0,0),(0,8),(8,0),(8,8),(4,4)]),
          goal:.allWhite, par:18),
        s(48, ch:10, size:9, title:"Maelstrom",
          grid:maelstrom9(), kinds:lockedSpine9(),
          goal:.allBlack, par:24),
        s(49, ch:10, size:9, title:"Terminus",
          grid:terminus9(), kinds:terminusKinds9(),
          goal:.allWhite, par:20),
        s(50, ch:10, size:9, title:"Monolith",
          grid:(0..<9).map{r in (0..<9).map{c in (r+c)%2==0}},
          kinds:monolithKinds9(),
          goal:.allBlack, par:0),
    ]

    // MARK: - Builder helpers

    private static func s(_ id: Int, ch: Int, size: Int, title: String,
                           grid: [[Bool]], kinds: [[TileKind]]? = nil,
                           goal: GoalKind, par: Int, time: Int = 0) -> StageSpec {
        StageSpec(id: id, chapter: ch, size: size, initial: grid, kinds: kinds,
                  goal: goal, parMoves: par, timeLimitSec: time, title: title)
    }

    // Uniform grids
    private static func b5(_ v: Bool) -> [[Bool]] { Array(repeating: Array(repeating: v, count:5), count:5) }
    private static func b7(_ v: Bool) -> [[Bool]] { Array(repeating: Array(repeating: v, count:7), count:7) }
    private static func b9(_ v: Bool) -> [[Bool]] { Array(repeating: Array(repeating: v, count:9), count:9) }

    // 5×5 kinds helpers
    private static func lockedCenter5() -> [[TileKind]] {
        var k = plain5(); k[2][2] = .locked; return k
    }
    private static func lockedCorners5() -> [[TileKind]] {
        var k = plain5()
        for (r,c) in [(0,0),(0,4),(4,0),(4,4)] { k[r][c] = .locked }
        return k
    }
    private static func lockedRing5() -> [[TileKind]] {
        var k = plain5()
        for r in 0..<5 { for c in 0..<5 { if r==0||r==4||c==0||c==4 { k[r][c] = .locked } } }
        return k
    }
    private static func bombCenter5() -> [[TileKind]] {
        var k = plain5(); k[2][2] = .bomb; return k
    }
    private static func mixedKinds5() -> [[TileKind]] {
        var k = plain5()
        k[0][0] = .locked; k[0][4] = .locked; k[4][0] = .locked; k[4][4] = .locked
        k[2][2] = .bomb; return k
    }
    private static func bombsAt5(_ positions: [(Int,Int)]) -> [[TileKind]] {
        var k = plain5()
        for (r,c) in positions { k[r][c] = .bomb }
        return k
    }
    private static func plain5() -> [[TileKind]] { Array(repeating: Array(repeating: .normal, count:5), count:5) }

    // 7×7 kinds helpers
    private static func lockedEdge7() -> [[TileKind]] {
        var k = plain7()
        for i in 0..<7 { k[0][i] = .locked; k[6][i] = .locked }
        return k
    }
    private static func bombGrid7() -> [[TileKind]] {
        var k = plain7()
        for r in [1,3,5] { for c in [1,3,5] { k[r][c] = .bomb } }
        return k
    }
    private static func lockedOuterRing7() -> [[TileKind]] {
        var k = plain7()
        for r in 0..<7 { for c in 0..<7 { if r==0||r==6||c==0||c==6 { k[r][c] = .locked } } }
        return k
    }
    private static func lockedCross7() -> [[TileKind]] {
        var k = plain7()
        for i in 0..<7 { k[3][i] = .locked; k[i][3] = .locked }
        return k
    }
    private static func bombsAt7(_ positions: [(Int,Int)]) -> [[TileKind]] {
        var k = plain7()
        for (r,c) in positions { k[r][c] = .bomb }
        return k
    }
    private static func lockedDiag7() -> [[TileKind]] {
        var k = plain7()
        for i in 0..<7 { k[i][i] = .locked; k[i][6-i] = .locked }
        return k
    }
    private static func lockedHalf7() -> [[TileKind]] {
        var k = plain7()
        for r in 0..<7 { for c in 0..<4 { k[r][c] = .locked } }
        return k
    }
    private static func plain7() -> [[TileKind]] { Array(repeating: Array(repeating: .normal, count:7), count:7) }

    // 9×9 kinds helpers
    private static func lockedOuterRing9() -> [[TileKind]] {
        var k = plain9()
        for r in 0..<9 { for c in 0..<9 { if r==0||r==8||c==0||c==8 { k[r][c] = .locked } } }
        return k
    }
    private static func bombsAt9(_ positions: [(Int,Int)]) -> [[TileKind]] {
        var k = plain9()
        for (r,c) in positions { k[r][c] = .bomb }
        return k
    }
    private static func lockedSpine9() -> [[TileKind]] {
        var k = plain9()
        for i in 0..<9 { k[4][i] = .locked; k[i][4] = .locked }
        return k
    }
    private static func monolithKinds9() -> [[TileKind]] {
        var k = plain9()
        for r in [0,2,4,6,8] { for c in [0,2,4,6,8] { k[r][c] = .locked } }
        return k
    }
    private static func plain9() -> [[TileKind]] { Array(repeating: Array(repeating: .normal, count:9), count:9) }

    // Complex grids
    private static func whirlpool9() -> [[Bool]] {
        (0..<9).map { r in (0..<9).map { c in
            let d = max(abs(r-4), abs(c-4))
            return d % 2 == 0
        }}
    }
    private static func voidCore9() -> [[Bool]] {
        (0..<9).map { r in (0..<9).map { c in
            let d = abs(r-4)+abs(c-4)
            return d > 0 && d <= 4
        }}
    }
    private static func maelstrom9() -> [[Bool]] {
        [[true,false,true,false,true,false,true,false,true],
         [false,true,false,true,false,true,false,true,false],
         [true,false,false,false,true,false,false,false,true],
         [false,true,false,true,false,true,false,true,false],
         [true,false,true,false,true,false,true,false,true],
         [false,true,false,true,false,true,false,true,false],
         [true,false,false,false,true,false,false,false,true],
         [false,true,false,true,false,true,false,true,false],
         [true,false,true,false,true,false,true,false,true]]
    }
    private static func terminus9() -> [[Bool]] {
        (0..<9).map { r in (0..<9).map { c in
            r == 0 || r == 8 || c == 0 || c == 8 || (r == 4 && c != 4) || (c == 4 && r != 4)
        }}
    }
    private static func terminusKinds9() -> [[TileKind]] {
        var k = plain9()
        for (r,c) in [(0,0),(0,4),(0,8),(4,0),(4,8),(8,0),(8,4),(8,8)] { k[r][c] = .bomb }
        for r in 1..<8 { for c in 1..<8 { if r==4||c==4 { k[r][c] = .locked } } }
        return k
    }
    private static func ruin7() -> [[Bool]] {
        [[true,false,true,false,true,false,true],
         [false,true,false,false,false,true,false],
         [true,false,false,true,false,false,true],
         [false,false,true,false,true,false,false],
         [true,false,false,true,false,false,true],
         [false,true,false,false,false,true,false],
         [true,false,true,false,true,false,true]]
    }
    private static func ruinKinds7() -> [[TileKind]] {
        var k = plain7()
        k[0][0] = .locked; k[0][6] = .locked; k[6][0] = .locked; k[6][6] = .locked
        k[2][3] = .bomb; k[4][3] = .bomb
        return k
    }
}
