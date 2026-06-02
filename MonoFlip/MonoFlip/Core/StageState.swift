import Foundation

// MARK: - Stage definition

enum GoalKind {
    case allWhite
    case allBlack
    case pattern([[Bool]])   // specific target pattern
}

struct StageSpec {
    let id: Int
    let chapter: Int
    let size: Int               // n×n
    let initial: [[Bool]]
    let kinds: [[TileKind]]?
    let goal: GoalKind
    let parMoves: Int           // 0 = no limit
    let timeLimitSec: Int       // 0 = no limit
    let title: String
}

// MARK: - Runtime state

enum SessionPhase {
    case idle, playing, paused, cleared, failed
}

final class BoardRuntime {
    private(set) var board: Board
    private(set) var moves: Int = 0
    private(set) var phase: SessionPhase = .idle
    private let spec: StageSpec

    var onMutation: (([TileMutation], Board) -> Void)?
    var onPhaseChange: ((SessionPhase) -> Void)?

    private var history: [Board] = []
    var canUndo: Bool { !history.isEmpty }

    init(spec: StageSpec) {
        self.spec = spec
        self.board = Board(rows: spec.size, cols: spec.size,
                           data: spec.initial, kinds: spec.kinds)
    }

    func start() {
        phase = .playing
        onPhaseChange?(.playing)
    }

    func tap(row: Int, col: Int) {
        guard phase == .playing else { return }
        guard !board[row, col].locked else { return }

        history.append(board)
        let result = TileMutationEngine.cross(board, row: row, col: col)
        board = result.board
        moves += 1

        onMutation?(result.mutations, board)
        checkGoal()
    }

    func undo() {
        guard let prev = history.popLast() else { return }
        board = prev
        moves = max(0, moves - 1)
        onMutation?([], board)
    }

    func restart() {
        history.removeAll()
        board = Board(rows: spec.size, cols: spec.size,
                      data: spec.initial, kinds: spec.kinds)
        moves = 0
        phase = .playing
        onMutation?([], board)
        onPhaseChange?(.playing)
    }

    private func checkGoal() {
        let cleared: Bool
        switch spec.goal {
        case .allWhite:   cleared = board.isAllLit
        case .allBlack:   cleared = board.isAllDark
        case .pattern(let target):
            cleared = (0..<spec.size).allSatisfy { r in
                (0..<spec.size).allSatisfy { c in board[r,c].lit == target[r][c] }
            }
        }
        if cleared {
            phase = .cleared
            onPhaseChange?(.cleared)
        } else if spec.parMoves > 0, moves >= spec.parMoves, !cleared {
            // moves-limited levels: check fail after move limit
            // we allow over-limit play; fail is checked by caller via timer or explicit
        }
    }
}

// MARK: - StageState  (persisted progress)

struct StageState: Codable {
    var unlocked: Bool
    var cleared: Bool
    var bestMoves: Int      // 0 = never cleared
}
