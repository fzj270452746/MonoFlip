import UIKit
import AudioToolbox

enum PlayMode {
    case normal
    case daily
    case timeAttack(remaining: Int)
}

final class PlayScreen: UIViewController {

    private let spec: StageSpec
    private let runtime: BoardRuntime
    private let mode: PlayMode

    private let hud = GameHUD()
    private let boardView = BoardView()
    private let undoBtn = UIButton(type: .system)
    private let restartBtn = UIButton(type: .system)
    private let hintBtn = UIButton(type: .system)
    private let closeBtn = UIButton(type: .system)
    private let goalBadge = UILabel()

    // Time Attack session timer
    private var taTimer: Timer?
    private var taRemaining: Int = 0
    private let taLabel = UILabel()

    // Mission tracking within this session
    private var usedUndo = false
    private var usedHint = false
    private var usedRestart = false

    init(spec: StageSpec, mode: PlayMode = .normal) {
        self.spec = spec
        self.mode = mode
        self.runtime = BoardRuntime(spec: spec)
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .coverVertical
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TP.bg
        buildUI()
        wire()
        runtime.start()
        hud.configure(spec: spec)
        hud.update(moves: 0, par: spec.parMoves)
        boardView.configure(board: runtime.board)
        updateToolbar()

        switch mode {
        case .timeAttack(let rem):
            taRemaining = rem
            startTimeAttack()
            Vault.shared.progressMission(id: "ta_do")
        case .daily:
            break
        case .normal:
            if spec.timeLimitSec > 0 {
                hud.startTimer()
                hud.onTimeUp = { [weak self] in self?.handleTimeFail() }
            }
        }

        // "play N stages" mission progress
        Vault.shared.progressMission(id: "play3")
        Vault.shared.progressMission(id: "play5")

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged),
                                               name: .themeDidChange, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hud.stopTimer()
        taTimer?.invalidate()
    }

    @objc private func themeChanged() {
        view.backgroundColor = TP.bg
    }

    // MARK: Build

    private func buildUI() {
        view.addSubview(hud)
        view.addSubview(boardView)
        view.addSubview(undoBtn)
        view.addSubview(restartBtn)
        view.addSubview(hintBtn)
        view.addSubview(closeBtn)
        view.addSubview(goalBadge)

        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = Palette.fog
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        styleToolButton(undoBtn, icon: "arrow.uturn.backward", label: "UNDO")
        undoBtn.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)

        styleToolButton(restartBtn, icon: "arrow.counterclockwise", label: "RESTART")
        restartBtn.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)

        styleToolButton(hintBtn, icon: "lightbulb", label: "HINT")
        hintBtn.addTarget(self, action: #selector(hintTapped), for: .touchUpInside)

        goalBadge.font = .systemFont(ofSize: Layout.scale(10), weight: .medium)
        goalBadge.textColor = Palette.ghost
        goalBadge.textAlignment = .center
        switch spec.goal {
        case .allWhite:  goalBadge.text = "GOAL: ALL WHITE"
        case .allBlack:  goalBadge.text = "GOAL: ALL BLACK"
        case .pattern:   goalBadge.text = "GOAL: MATCH PATTERN"
        }

        taLabel.font = .monospacedDigitSystemFont(ofSize: Layout.scale(28), weight: .semibold)
        taLabel.textColor = Palette.warn
        taLabel.textAlignment = .center
        taLabel.isHidden = true
        view.addSubview(taLabel)
    }

    private func styleToolButton(_ btn: UIButton, icon: String, label: String) {
        btn.tintColor = Palette.fog
        btn.setTitleColor(Palette.fog, for: .normal)
        btn.setTitleColor(Palette.fog.withAlphaComponent(0.4), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: Layout.scale(9), weight: .medium)

        if #available(iOS 15, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: icon)
            config.imagePlacement = .top
            config.imagePadding = Layout.scale(4)
            config.title = label
            config.baseForegroundColor = Palette.fog
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
                var a = attr; a.font = UIFont.systemFont(ofSize: Layout.scale(9), weight: .medium)
                return a
            }
            btn.configuration = config
        } else {
            btn.setImage(UIImage(systemName: icon), for: .normal)
            btn.setTitle(label, for: .normal)
            btn.titleEdgeInsets = UIEdgeInsets(top: Layout.scale(28), left: -24, bottom: 0, right: 0)
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: Layout.scale(14), right: 0)
        }
    }

    // MARK: Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let w = view.bounds.width
        let h = view.bounds.height

        closeBtn.frame = CGRect(x: w - Layout.scale(52), y: safe.top + Layout.scale(8),
                                width: Layout.scale(44), height: Layout.scale(44))

        let hudH = Layout.scale(60)
        hud.frame = CGRect(x: Layout.scale(20), y: safe.top + Layout.scale(12),
                           width: w - Layout.scale(80), height: hudH)

        goalBadge.frame = CGRect(x: 0, y: safe.top + hudH + Layout.scale(16),
                                 width: w, height: Layout.scale(16))

        if !taLabel.isHidden {
            taLabel.frame = CGRect(x: 0, y: safe.top + Layout.scale(12),
                                   width: w, height: hudH)
        }

        let toolbarH = Layout.scale(80)
        let usableH = h - safe.top - hudH - Layout.scale(36) - toolbarH - safe.bottom
        let boardPad = Layout.scale(20)
        let boardSide = min(w - boardPad*2, usableH - boardPad)
        let boardX = (w - boardSide) / 2
        let boardY = safe.top + hudH + Layout.scale(40)
        boardView.frame = CGRect(x: boardX, y: boardY, width: boardSide, height: boardSide)

        let toolbarY = h - safe.bottom - toolbarH
        let toolW = w / 3
        undoBtn.frame = CGRect(x: 0, y: toolbarY, width: toolW, height: toolbarH)
        restartBtn.frame = CGRect(x: toolW, y: toolbarY, width: toolW, height: toolbarH)
        hintBtn.frame = CGRect(x: toolW*2, y: toolbarY, width: toolW, height: toolbarH)
    }

    // MARK: Wire

    private func wire() {
        boardView.onTap = { [weak self] r, c in
            self?.runtime.tap(row: r, col: c)
            Haptic.tap()
            SFX.flip()
        }

        runtime.onMutation = { [weak self] mutations, board in
            guard let self else { return }
            boardView.applyMutations(mutations, board: board)
            hud.update(moves: runtime.moves, par: spec.parMoves)
            updateToolbar()
        }

        runtime.onPhaseChange = { [weak self] phase in
            guard let self else { return }
            switch phase {
            case .cleared: handleCleared()
            default: break
            }
        }
    }

    private func updateToolbar() {
        undoBtn.isEnabled = runtime.canUndo
        undoBtn.alpha = runtime.canUndo ? 1 : 0.35
    }

    // MARK: Time Attack

    private func startTimeAttack() {
        taLabel.isHidden = false
        updateTALabel()
        taTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            taRemaining -= 1
            updateTALabel()
            if taRemaining <= 0 {
                taTimer?.invalidate()
                endTimeAttack()
            }
        }
    }

    private func updateTALabel() {
        let m = taRemaining / 60; let s = taRemaining % 60
        taLabel.text = String(format: "%d:%02d", m, s)
    }

    private func endTimeAttack() {
        Haptic.fail()
        let current = Vault.shared.timeAttackStagesThisSession
        let score = Vault.shared.timeAttackHighScore

        // achievements
        checkAndToast(Vault.shared.unlockAchievement("ta_first"))
        if current >= 10 { checkAndToast(Vault.shared.unlockAchievement("ta_ten")) }
        if current >= 20 { checkAndToast(Vault.shared.unlockAchievement("ta_twenty")) }

        OverlayPanel.show(on: self, title: "Time's Up",
                          body: "Cleared \(current) stage\(current == 1 ? "" : "s")\nBest: \(score)",
                          actions: [
                            .init(title: "Try Again", style: .primary) { [weak self] in
                                self?.restartTimeAttack()
                            },
                            .init(title: "Exit", style: .secondary) { [weak self] in
                                self?.dismiss(animated: true)
                            }
                          ])
    }

    private func restartTimeAttack() {
        Vault.shared.resetTimeAttackSession()
        guard let first = StageCatalog.all.first else { return }
        let presenter = presentingViewController
        dismiss(animated: false) {
            let vc = PlayScreen(spec: first, mode: .timeAttack(remaining: 180))
            vc.modalPresentationStyle = .fullScreen
            presenter?.present(vc, animated: true)
        }
    }

    // MARK: Actions

    @objc private func closeTapped() {
        if case .timeAttack = mode {
            endTimeAttack()
            return
        }
        OverlayPanel.show(on: self, title: "Quit Stage?", body: "Progress will not be saved.",
                         actions: [
                            .init(title: "Quit", style: .destructive) { [weak self] in
                                self?.dismiss(animated: true)
                            },
                            .init(title: "Keep Playing", style: .primary) {},
                         ])
    }

    @objc private func undoTapped() {
        guard runtime.canUndo else { return }
        runtime.undo()
        Haptic.bump()
        SFX.undo()
        usedUndo = true
        Vault.shared.progressMission(id: "undo3")
    }

    @objc private func restartTapped() {
        OverlayPanel.show(on: self, title: "Restart?", body: "Board will be reset.",
                         actions: [
                            .init(title: "Restart", style: .destructive) { [weak self] in
                                self?.runtime.restart()
                                self?.usedRestart = true
                            },
                            .init(title: "Cancel", style: .secondary) {},
                         ])
    }

    @objc private func hintTapped() {
        usedHint = true
        OverlayPanel.show(on: self, title: "Hint", body: buildHintText(),
                         actions: [.init(title: "Got it", style: .primary) {}])
    }

    private func buildHintText() -> String {
        var parts = ["Each tap flips the cell and its 4 neighbors."]
        if spec.parMoves > 0 { parts.append("Par is \(spec.parMoves) moves — try to beat it.") }
        if spec.kinds?.flatMap({$0}).contains(where: {$0 == .locked}) == true {
            parts.append("Gray tiles (🔒) cannot be flipped — work around them.")
        }
        if spec.kinds?.flatMap({$0}).contains(where: {$0 == .bomb}) == true {
            parts.append("Bomb tiles (◉) flip a 3×3 area when hit.")
        }
        return parts.joined(separator: "\n\n")
    }

    // MARK: Time fail

    private func handleTimeFail() {
        Haptic.fail()
        OverlayPanel.show(on: self, title: "Time's Up", body: "You ran out of time.",
                         actions: [
                            .init(title: "Retry", style: .primary) { [weak self] in
                                self?.runtime.restart()
                                self?.hud.startTimer()
                            },
                            .init(title: "Quit", style: .secondary) { [weak self] in
                                self?.dismiss(animated: true)
                            }
                         ])
    }

    // MARK: Victory

    private func handleCleared() {
        hud.stopTimer()
        Haptic.success()
        SFX.cleared()

        switch mode {
        case .daily:
            Vault.shared.recordDailyCompleted(id: DailyPuzzle.todayID)
            checkAndToast(Vault.shared.unlockAchievement("daily_first"))
            let dailyCount = Vault.shared.unlockedAchievements.contains("daily_first") ? 1 : 0
            _ = dailyCount
            Vault.shared.progressMission(id: "daily_do")
        case .normal:
            Vault.shared.record(stageID: spec.id, moves: runtime.moves)
            checkNormalAchievements()
        case .timeAttack:
            Vault.shared.recordTimeAttackStage()
            boardView.burstVictory { [weak self] in
                guard let self else { return }
                goToNextTimeAttack()
            }
            return
        }

        // mission: clear stages
        Vault.shared.progressMission(id: "clear3")
        Vault.shared.progressMission(id: "clear5")
        if !usedHint { checkAndToast(Vault.shared.progressMission(id: "nohint")) }
        if !usedRestart { Vault.shared.progressMission(id: "restart0") }

        boardView.burstVictory { [weak self] in
            guard let self else { return }
            showClearedPanel()
        }
    }

    private func checkNormalAchievements() {
        let moves = runtime.moves
        let par = spec.parMoves

        checkAndToast(Vault.shared.unlockAchievement("first_clear"))

        // Chapter completions
        let allStages = StageCatalog.all
        let ch1Done = allStages.filter { $0.chapter == 1 }.allSatisfy { Vault.shared.state(for: $0.id).cleared }
        if ch1Done { checkAndToast(Vault.shared.unlockAchievement("ch1_done")) }
        let ch5Done = allStages.filter { $0.chapter == 5 }.allSatisfy { Vault.shared.state(for: $0.id).cleared }
        if ch5Done { checkAndToast(Vault.shared.unlockAchievement("ch5_done")) }
        let allDone = allStages.allSatisfy { Vault.shared.state(for: $0.id).cleared }
        if allDone { checkAndToast(Vault.shared.unlockAchievement("ch10_done")) }

        // Stars
        if par > 0 && moves <= par {
            checkAndToast(Vault.shared.unlockAchievement("star3_first"))
            let threeStarCount = allStages.filter { s in
                let st = Vault.shared.state(for: s.id)
                return st.cleared && s.parMoves > 0 && st.bestMoves <= s.parMoves
            }.count
            if threeStarCount >= 10 { checkAndToast(Vault.shared.unlockAchievement("star3_ten")) }

            // mission
            Vault.shared.progressMission(id: "star3_one")
        }
        if par > 0 && moves == par { checkAndToast(Vault.shared.unlockAchievement("moves_exact")) }
        if !usedUndo { checkAndToast(Vault.shared.unlockAchievement("undo_never")) }
    }

    private func showClearedPanel() {
        let under = runtime.moves
        let par = spec.parMoves
        var bodyParts = ["Solved in \(under) move\(under == 1 ? "" : "s")."]

        let stars = par > 0 ? starsEarned(moves: under, par: par) : 0
        if par > 0 {
            let starStr = String(repeating: "★", count: stars) + String(repeating: "☆", count: 3 - stars)
            bodyParts.append(starStr)
            if under <= par { bodyParts.append("Under par — excellent!") }
            else { bodyParts.append("Par is \(par). Try to improve!") }
        }

        let pts = Vault.shared.achievementPoints
        bodyParts.append("⬡ \(pts) pts total")

        let isDaily = (mode == .daily || spec.chapter == 0)
        let hasNext = !isDaily && StageCatalog.all.first(where: { $0.id == spec.id + 1 }) != nil

        var actions: [OverlayPanel.Action] = []
        if hasNext {
            actions.append(.init(title: "Next Stage", style: .primary) { [weak self] in self?.goToNext() })
        }
        actions.append(.init(title: isDaily ? "Done" : "Stage Select",
                             style: hasNext ? .secondary : .primary) { [weak self] in
            self?.dismiss(animated: true)
        })

        OverlayPanel.show(on: self, title: "Cleared ✓",
                          body: bodyParts.joined(separator: "\n"), actions: actions)
    }

    private func starsEarned(moves: Int, par: Int) -> Int {
        if moves <= par { return 3 }
        if moves <= par + 3 { return 2 }
        return 1
    }

    private func goToNext() {
        guard let next = StageCatalog.all.first(where: { $0.id == spec.id + 1 }),
              Vault.shared.isUnlocked(next.id) else {
            dismiss(animated: true); return
        }
        let presenter = presentingViewController
        dismiss(animated: true) {
            let vc = PlayScreen(spec: next)
            vc.modalPresentationStyle = .fullScreen
            presenter?.present(vc, animated: true)
        }
    }

    private func goToNextTimeAttack() {
        guard let next = StageCatalog.all.first(where: { $0.id == spec.id + 1 }) else {
            endTimeAttack(); return
        }
        let presenter = presentingViewController
        dismiss(animated: false) {
            let vc = PlayScreen(spec: next, mode: .timeAttack(remaining: self.taRemaining))
            vc.modalPresentationStyle = .fullScreen
            presenter?.present(vc, animated: false)
        }
    }

    // MARK: Toast for achievements/missions

    private func checkAndToast(_ ach: Achievement?) {
        guard let ach else { return }
        showToast("🏆 \(ach.title) +\(ach.points)pts")
    }

    private func checkAndToast(_ mission: DailyMission?) {
        guard let m = mission else { return }
        showToast("✓ \(m.title) +\(m.points)pts")
    }

    func showToast(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.font = .systemFont(ofSize: Layout.scale(12), weight: .semibold)
        toast.textColor = Palette.paper
        toast.textAlignment = .center
        toast.backgroundColor = Palette.dim.withAlphaComponent(0.92)
        toast.layer.cornerRadius = Layout.scale(10)
        toast.clipsToBounds = true
        toast.alpha = 0
        view.addSubview(toast)

        let w = min(view.bounds.width - Layout.scale(40), 320)
        let h = Layout.scale(36)
        toast.frame = CGRect(x: (view.bounds.width - w)/2,
                             y: view.safeAreaInsets.top + Layout.scale(80),
                             width: w, height: h)

        UIView.animate(withDuration: 0.3) { toast.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            UIView.animate(withDuration: 0.3) { toast.alpha = 0 } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

extension PlayMode: Equatable {
    static func == (lhs: PlayMode, rhs: PlayMode) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .normal), (.daily, .daily): return true
        case (.timeAttack, .timeAttack): return true
        default: return false
        }
    }
}
