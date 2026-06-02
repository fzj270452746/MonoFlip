import UIKit

// HUD bar shown at top of game screen.

final class GameHUD: UIView {
    private let chapterLabel = UILabel()
    private let stageLabel = UILabel()
    private let movesValue = UILabel()
    private let movesCaption = UILabel()
    private let parValue = UILabel()
    private let parCaption = UILabel()
    private let timerLabel = UILabel()
    private let starsRow = StarRow()

    private var timer: Timer?
    private var elapsed: Int = 0
    private var timeLimit: Int = 0
    var onTimeUp: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear

        chapterLabel.font = .systemFont(ofSize: Layout.scale(11), weight: .medium)
        chapterLabel.textColor = Palette.ghost
        chapterLabel.textAlignment = .left

        stageLabel.font = .systemFont(ofSize: Layout.scale(18), weight: .bold)
        stageLabel.textColor = Palette.paper
        stageLabel.textAlignment = .left

        movesValue.font = .monospacedDigitSystemFont(ofSize: Layout.scale(28), weight: .thin)
        movesValue.textColor = Palette.paper
        movesValue.textAlignment = .right

        movesCaption.font = .systemFont(ofSize: Layout.scale(10), weight: .medium)
        movesCaption.text = "MOVES"
        movesCaption.textColor = Palette.ghost
        movesCaption.textAlignment = .right

        parValue.font = .monospacedDigitSystemFont(ofSize: Layout.scale(16), weight: .thin)
        parValue.textColor = Palette.spark
        parValue.textAlignment = .right

        parCaption.font = .systemFont(ofSize: Layout.scale(10), weight: .medium)
        parCaption.text = "PAR"
        parCaption.textColor = Palette.ghost
        parCaption.textAlignment = .right

        timerLabel.font = .monospacedDigitSystemFont(ofSize: Layout.scale(16), weight: .thin)
        timerLabel.textColor = Palette.warn
        timerLabel.textAlignment = .right
        timerLabel.isHidden = true

        for v in [chapterLabel, stageLabel, movesValue, movesCaption,
                  parValue, parCaption, timerLabel, starsRow] {
            addSubview(v)
        }
    }

    func configure(spec: StageSpec) {
        if spec.chapter == 0 {
            chapterLabel.text = "DAILY PUZZLE"
        } else {
            chapterLabel.text = "CHAPTER \(spec.chapter)"
        }
        stageLabel.text = spec.title.uppercased()
        parValue.isHidden = spec.parMoves == 0
        parCaption.isHidden = spec.parMoves == 0
        if spec.parMoves > 0 { parValue.text = "\(spec.parMoves)" }

        timeLimit = spec.timeLimitSec
        timerLabel.isHidden = spec.timeLimitSec == 0

        starsRow.isHidden = spec.parMoves == 0
    }

    func startTimer() {
        guard timeLimit > 0 else { return }
        elapsed = 0
        updateTimerLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            elapsed += 1
            updateTimerLabel()
            if elapsed >= timeLimit {
                timer?.invalidate(); timer = nil
                onTimeUp?()
            }
        }
    }

    func stopTimer() { timer?.invalidate(); timer = nil }

    func update(moves: Int, par: Int = 0) {
        movesValue.text = "\(moves)"
        bump(movesValue)
        if par > 0 { starsRow.update(moves: moves, par: par) }
    }

    private func updateTimerLabel() {
        let remaining = max(0, timeLimit - elapsed)
        let m = remaining / 60; let s = remaining % 60
        timerLabel.text = String(format: "%d:%02d", m, s)
        if remaining <= 10 { timerLabel.textColor = Palette.warn; bump(timerLabel) }
    }

    private func bump(_ v: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.values = [1.0, 1.18, 0.95, 1.0]
        anim.duration = 0.25
        v.layer.add(anim, forKey: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let h = bounds.height
        let w = bounds.width

        chapterLabel.frame = CGRect(x: 0, y: 0, width: w*0.55, height: h*0.35)
        stageLabel.frame = CGRect(x: 0, y: h*0.36, width: w*0.6, height: h*0.4)
        starsRow.frame = CGRect(x: 0, y: h*0.76, width: Layout.scale(60), height: h*0.24)

        let rightW = Layout.scale(70)
        movesCaption.frame = CGRect(x: w-rightW, y: 0, width: rightW, height: h*0.3)
        movesValue.frame = CGRect(x: w-rightW, y: h*0.28, width: rightW, height: h*0.65)

        let pW = Layout.scale(50)
        let px = w - rightW - pW - Layout.scale(8)
        if !parValue.isHidden {
            parCaption.frame = CGRect(x: px, y: 0, width: pW, height: h*0.3)
            parValue.frame = CGRect(x: px, y: h*0.28, width: pW, height: h*0.65)
        }
        if !timerLabel.isHidden {
            let tx = w - rightW - pW - Layout.scale(8)
            timerLabel.frame = CGRect(x: tx, y: h*0.28, width: pW, height: h*0.65)
        }
    }
}

// MARK: - Star row

private final class StarRow: UIView {
    private let stars = (0..<3).map { _ -> UIView in
        let v = UIView(); v.layer.cornerRadius = 3; return v
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        stars.forEach { addSubview($0) }
        update(moves: 0, par: 0)
    }
    required init?(coder: NSCoder) { fatalError() }

    func update(moves: Int, par: Int) {
        guard par > 0 else { return }
        // 3 stars: ≤ par; 2 stars: ≤ par+3; 1 star: solved
        let earned = moves == 0 ? 0 : (moves <= par ? 3 : moves <= par + 3 ? 2 : 1)
        for (i, star) in stars.enumerated() {
            star.backgroundColor = i < earned ? Palette.spark : Palette.mist
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let side = min(bounds.height, Layout.scale(8))
        let gap = Layout.scale(3)
        for (i, star) in stars.enumerated() {
            star.frame = CGRect(x: CGFloat(i) * (side + gap), y: (bounds.height - side)/2,
                                width: side, height: side)
            star.layer.cornerRadius = side / 2
        }
    }
}
