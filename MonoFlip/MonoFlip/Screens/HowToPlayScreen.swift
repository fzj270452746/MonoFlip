import UIKit

final class HowToPlayScreen: UIViewController {

    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let closeBtn = UIButton(type: .system)
    private let demoBoard = InteractiveDemoBoard()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.void
        build()
    }

    private func build() {
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = Palette.fog
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeBtn)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        stack.axis = .vertical
        stack.spacing = Layout.scale(28)
        stack.alignment = .fill
        scrollView.addSubview(stack)

        addTitle("HOW TO PLAY")
        addSection(icon: "hand.tap",
                   title: "Tap a tile",
                   body: "Tapping any tile flips it AND its four orthogonal neighbors (up, down, left, right).")
        addSection(icon: "checkmark.square",
                   title: "Match the goal",
                   body: "Your goal is shown at the top. Most stages ask you to make ALL tiles the same color — either all white or all black.")
        addSection(icon: "lock.fill",
                   title: "Locked tiles",
                   body: "Gray locked tiles (🔒) cannot be flipped by themselves, but neighboring taps still flip them. Plan around them.")
        addSection(icon: "circle.fill",
                   title: "Bomb tiles",
                   body: "Bomb tiles (◉) explode when tapped — they flip the entire 3×3 area surrounding them, giving you extra reach.")
        addSection(icon: "star.fill",
                   title: "Par & Stars",
                   body: "Each stage has a par (target move count). Solve in ≤ par moves for 3 ★, ≤ par+3 for 2 ★, or just clear it for 1 ★.")
        addSection(icon: "arrow.uturn.backward",
                   title: "Undo",
                   body: "Made a mistake? Tap UNDO to step back one move at a time. You can undo all the way to the start.")

        addDemoSection()

        addSection(icon: "calendar",
                   title: "Daily Puzzle",
                   body: "A new puzzle is generated every day. Complete it for bonus achievement points. Streaks unlock achievements.")
        addSection(icon: "timer",
                   title: "Time Attack",
                   body: "Race against 3 minutes. Clear as many stages as possible in sequence — the clock never stops.")
    }

    private func addTitle(_ text: String) {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: Layout.scale(13), weight: .medium)
        l.textColor = Palette.ghost
        l.textAlignment = .center
        stack.addArrangedSubview(l)
    }

    private func addSection(icon: String, title: String, body: String) {
        let card = RuleCard(icon: icon, title: title, body: body)
        stack.addArrangedSubview(card)
    }

    private func addDemoSection() {
        let header = UILabel()
        header.text = "TRY IT"
        header.font = .systemFont(ofSize: Layout.scale(11), weight: .medium)
        header.textColor = Palette.ghost
        header.textAlignment = .center
        stack.addArrangedSubview(header)

        let hint = UILabel()
        hint.text = "Tap the tiles below to see how flipping works"
        hint.font = .systemFont(ofSize: Layout.scale(12), weight: .regular)
        hint.textColor = Palette.fog
        hint.textAlignment = .center
        hint.numberOfLines = 2
        stack.addArrangedSubview(hint)

        stack.addArrangedSubview(demoBoard)
        demoBoard.translatesAutoresizingMaskIntoConstraints = false
        demoBoard.heightAnchor.constraint(equalTo: demoBoard.widthAnchor).isActive = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let w = view.bounds.width
        let h = view.bounds.height

        closeBtn.frame = CGRect(x: Layout.scale(16), y: safe.top + Layout.scale(12), width: 44, height: 44)

        let top = safe.top + Layout.scale(64)
        scrollView.frame = CGRect(x: 0, y: top, width: w, height: h - top)

        let pad = Layout.scale(20)
        let cw = min(w - pad*2, 440)
        let cx = (w - cw) / 2
        stack.frame = CGRect(x: cx, y: pad, width: cw, height: stack.systemLayoutSizeFitting(
            CGSize(width: cw, height: UIView.layoutFittingCompressedSize.height)).height)
        scrollView.contentSize = CGSize(width: w, height: stack.frame.maxY + pad)
    }

    @objc private func close() { dismiss(animated: true) }
}

// MARK: - Rule card

private final class RuleCard: UIView {
    init(icon: String, title: String, body: String) {
        super.init(frame: .zero)
        backgroundColor = Palette.dim
        layer.cornerRadius = Layout.scale(14)
        layer.cornerCurve = .continuous

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = Palette.spark
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)

        let titleL = UILabel()
        titleL.text = title
        titleL.font = .systemFont(ofSize: Layout.scale(15), weight: .semibold)
        titleL.textColor = Palette.paper
        addSubview(titleL)

        let bodyL = UILabel()
        bodyL.text = body
        bodyL.font = .systemFont(ofSize: Layout.scale(13), weight: .regular)
        bodyL.textColor = Palette.fog
        bodyL.numberOfLines = 0
        addSubview(bodyL)

        for v in [iconView, titleL, bodyL] { v.translatesAutoresizingMaskIntoConstraints = false }

        let pad = Layout.scale(16)
        let iconS = Layout.scale(24)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            iconView.widthAnchor.constraint(equalToConstant: iconS),
            iconView.heightAnchor.constraint(equalToConstant: iconS),

            titleL.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: Layout.scale(10)),
            titleL.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            titleL.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),

            bodyL.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: Layout.scale(10)),
            bodyL.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            bodyL.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            bodyL.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Interactive 3×3 demo board

private final class InteractiveDemoBoard: UIView {
    private var lit: [[Bool]] = Array(repeating: Array(repeating: false, count: 3), count: 3)
    private var cells: [[UIView]] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        // start with a random-ish pattern
        lit = [[true, false, true], [false, true, false], [true, false, true]]
        buildCells()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildCells() {
        for r in 0..<3 {
            var row: [UIView] = []
            for c in 0..<3 {
                let v = UIView()
                v.layer.cornerRadius = Layout.scale(8)
                v.layer.cornerCurve = .continuous
                v.backgroundColor = lit[r][c] ? Palette.paper : Palette.mist
                addSubview(v)
                let tap = UITapGestureRecognizer(target: self,
                    action: #selector(tapped(_:)))
                v.addGestureRecognizer(tap)
                v.tag = r * 3 + c
                row.append(v)
            }
            cells.append(row)
        }
    }

    @objc private func tapped(_ g: UITapGestureRecognizer) {
        let tag = g.view?.tag ?? 0
        let r = tag / 3; let c = tag % 3
        let neighbors = [(r,c),(r-1,c),(r+1,c),(r,c-1),(r,c+1)]
        for (nr, nc) in neighbors {
            guard nr >= 0, nr < 3, nc >= 0, nc < 3 else { continue }
            lit[nr][nc].toggle()
            UIView.transition(with: cells[nr][nc], duration: 0.2,
                              options: [.transitionFlipFromTop]) {
                self.cells[nr][nc].backgroundColor = self.lit[nr][nc] ? Palette.paper : Palette.mist
            }
        }
        Haptic.tap()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let n = 3
        let gap = Layout.scale(6)
        let side = (bounds.width - gap * CGFloat(n-1)) / CGFloat(n)
        let offsetX = (bounds.width - (side * CGFloat(n) + gap * CGFloat(n-1))) / 2
        let offsetY = (bounds.height - (side * CGFloat(n) + gap * CGFloat(n-1))) / 2
        for r in 0..<n { for c in 0..<n {
            cells[r][c].frame = CGRect(
                x: offsetX + CGFloat(c) * (side + gap),
                y: offsetY + CGFloat(r) * (side + gap),
                width: side, height: side)
        }}
    }
}
