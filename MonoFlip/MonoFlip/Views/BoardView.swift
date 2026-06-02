import UIKit

// MARK: - Tile cell view

final class TileCell: UIView {
    private let inner = UIView()
    private let lockIcon = UILabel()
    private let bombIcon = UILabel()

    var onTap: (() -> Void)?

    private(set) var tile: Tile = Tile(lit: false, kind: .normal)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged),
                                               name: .themeDidChange, object: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    deinit { NotificationCenter.default.removeObserver(self) }

    private func setup() {
        backgroundColor = .clear
        inner.layer.cornerRadius = Layout.scale(4)
        inner.clipsToBounds = true
        addSubview(inner)
        inner.translatesAutoresizingMaskIntoConstraints = false
        let gap = Layout.scale(3)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: topAnchor, constant: gap),
            inner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -gap),
            inner.leadingAnchor.constraint(equalTo: leadingAnchor, constant: gap),
            inner.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -gap),
        ])

        lockIcon.text = "🔒"
        lockIcon.font = .systemFont(ofSize: Layout.scale(12))
        lockIcon.textAlignment = .center

        bombIcon.text = "◉"
        bombIcon.font = .systemFont(ofSize: Layout.scale(14))
        bombIcon.textAlignment = .center
        bombIcon.textColor = Palette.warn

        for icon in [lockIcon, bombIcon] {
            inner.addSubview(icon)
            icon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: inner.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: inner.centerYAnchor),
            ])
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    func configure(_ t: Tile) {
        tile = t
        applyColors()
        lockIcon.isHidden = t.kind != .locked
        bombIcon.isHidden = t.kind != .bomb
    }

    private func applyColors() {
        inner.backgroundColor = tile.lit ? TP.lit : TP.unlit
        inner.layer.borderWidth = tile.lit ? 0 : 1
        inner.layer.borderColor = TP.mist.cgColor
        lockIcon.textColor = tile.lit ? Palette.ghost : Palette.fog
    }

    func flip(toLit lit: Bool, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            UIView.transition(with: self.inner,
                              duration: 0.22,
                              options: [.transitionFlipFromTop, .curveEaseInOut]) {
                self.inner.backgroundColor = lit ? TP.lit : TP.unlit
                self.inner.layer.borderWidth = lit ? 0 : 1
                self.lockIcon.textColor = lit ? Palette.ghost : Palette.fog
            }
        }
    }

    func pulse() {
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.values = [1.0, 1.12, 0.95, 1.0]
        anim.duration = 0.3
        anim.timingFunctions = [.init(name: .easeOut)]
        inner.layer.add(anim, forKey: "pulse")
    }

    @objc private func tapped() { onTap?() }

    @objc private func themeChanged() {
        applyColors()
    }
}

// MARK: - Board view

final class BoardView: UIView {
    private var cells: [[TileCell]] = []
    var onTap: ((Int, Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged),
                                               name: .themeDidChange, object: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    deinit { NotificationCenter.default.removeObserver(self) }

    func configure(board: Board) {
        cells.forEach { $0.forEach { $0.removeFromSuperview() } }
        cells = []

        let n = board.rows
        cells = (0..<n).map { r in
            (0..<n).map { c in
                let cell = TileCell()
                cell.configure(board[r, c])
                cell.onTap = { [weak self] in self?.onTap?(r, c) }
                addSubview(cell)
                return cell
            }
        }
        setNeedsLayout()
    }

    func applyMutations(_ mutations: [TileMutation], board: Board) {
        guard !cells.isEmpty else { return }
        for (i, m) in mutations.enumerated() {
            let cell = cells[m.row][m.col]
            let delay = Double(i) * 0.03
            cell.flip(toLit: board[m.row, m.col].lit, delay: delay)
        }
        if mutations.isEmpty {
            let n = board.rows
            for r in 0..<n { for c in 0..<n {
                cells[r][c].configure(board[r, c])
            }}
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !cells.isEmpty else { return }
        let n = cells.count
        let side = bounds.width / CGFloat(n)
        for r in 0..<n { for c in 0..<n {
            cells[r][c].frame = CGRect(x: CGFloat(c)*side, y: CGFloat(r)*side,
                                       width: side, height: side)
        }}
    }

    func burstVictory(completion: @escaping () -> Void) {
        guard !cells.isEmpty else { completion(); return }
        let n = cells.count
        let center = CGPoint(x: CGFloat(n)/2, y: CGFloat(n)/2)
        var maxDelay: TimeInterval = 0
        for r in 0..<n { for c in 0..<n {
            let dist = sqrt(pow(Double(r)-center.x, 2)+pow(Double(c)-center.y, 2))
            let delay = dist * 0.06
            maxDelay = max(maxDelay, delay)
            cells[r][c].pulse()
            let cell = cells[r][c]
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                UIView.animate(withDuration: 0.15) {
                    cell.alpha = 0.4
                } completion: { _ in
                    UIView.animate(withDuration: 0.15) { cell.alpha = 1 }
                }
            }
        }}
        DispatchQueue.main.asyncAfter(deadline: .now() + maxDelay + 0.35, execute: completion)
    }

    @objc private func themeChanged() {
        // cells re-apply colors individually via their own observer
        backgroundColor = TP.bg
    }
}
