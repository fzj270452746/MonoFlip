import UIKit

final class ChapterScreen: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let headerLabel = UILabel()
    private let backHint = UILabel()
    private let modesBtn = UIButton(type: .system)

    private let chapters: [(Int, String, String)] = [
        (1,  "I",    "Basics"),
        (2,  "II",   "Economy"),
        (3,  "III",  "Obstacles"),
        (4,  "IV",   "Labyrinth"),
        (5,  "V",    "Hell"),
        (6,  "VI",   "Fission"),
        (7,  "VII",  "Armory"),
        (8,  "VIII", "Vortex"),
        (9,  "IX",   "Cipher"),
        (10, "X",    "Endgame"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.void
        setup()
        buildChapterCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildChapterCards()
    }

    private func setup() {
        headerLabel.text = "SELECT CHAPTER"
        headerLabel.font = .systemFont(ofSize: Layout.scale(11), weight: .medium)
        headerLabel.textColor = Palette.ghost
        headerLabel.textAlignment = .center
        view.addSubview(headerLabel)

        backHint.text = "← MONO FLIP"
        backHint.font = .systemFont(ofSize: Layout.scale(13), weight: .semibold)
        backHint.textColor = Palette.fog
        view.addSubview(backHint)
        backHint.isUserInteractionEnabled = true
        backHint.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))

        modesBtn.setImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
        modesBtn.tintColor = Palette.fog
        modesBtn.addTarget(self, action: #selector(openModes), for: .touchUpInside)
        view.addSubview(modesBtn)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = Layout.scale(16)
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
    }

    private func buildChapterCards() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let grouped = Dictionary(grouping: StageCatalog.all, by: { $0.chapter })

        for (chIdx, numeral, name) in chapters {
            let stages = (grouped[chIdx] ?? []).sorted { $0.id < $1.id }
            // Chapter locked if first stage not unlocked
            let locked = !Vault.shared.isUnlocked(stages.first?.id ?? (chIdx * 5 - 4))
            let card = ChapterCard(chapterIndex: chIdx, numeral: numeral, name: name,
                                   stages: stages, locked: locked)
            card.onStageTap = { [weak self] spec in self?.openStage(spec) }
            contentStack.addArrangedSubview(card)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let topY = safe.top + Layout.scale(12)
        backHint.frame = CGRect(x: Layout.scale(20), y: topY, width: 160, height: 32)
        headerLabel.frame = CGRect(x: 0, y: topY + 8, width: view.bounds.width, height: 20)
        modesBtn.frame = CGRect(x: view.bounds.width - Layout.scale(52), y: topY,
                                width: 44, height: 32)

        let scrollTop = topY + Layout.scale(48)
        scrollView.frame = CGRect(x: 0, y: scrollTop,
                                  width: view.bounds.width,
                                  height: view.bounds.height - scrollTop)

        let pad = Layout.scale(20)
        let cardW = min(view.bounds.width - pad*2, 440)
        let cardX = (view.bounds.width - cardW) / 2

        let cardH = Layout.scale(16) + Layout.scale(14) + Layout.scale(16) + Layout.scale(24)
                  + Layout.scale(8) + Layout.scale(54) + Layout.scale(16)
        let totalH = cardH * CGFloat(chapters.count)
                   + contentStack.spacing * CGFloat(chapters.count - 1)
                   + pad * 2

        contentStack.frame = CGRect(x: cardX, y: pad, width: cardW, height: totalH)
        scrollView.contentSize = CGSize(width: view.bounds.width, height: totalH + pad * 2)
    }

    private func openStage(_ spec: StageSpec) {
        guard Vault.shared.isUnlocked(spec.id) else { return }
        let vc = PlayScreen(spec: spec)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func goBack() { dismiss(animated: true) }

    @objc private func openModes() {
        let vc = SpecialModesScreen()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: - Chapter card

private final class ChapterCard: UIView {
    var onStageTap: ((StageSpec) -> Void)?

    private let chNumeral = UILabel()
    private let chName = UILabel()
    private let grid = UIStackView()
    private let lockOverlay = UIView()

    init(chapterIndex: Int, numeral: String, name: String,
         stages: [StageSpec], locked: Bool) {
        super.init(frame: .zero)

        backgroundColor = locked ? Palette.dim.withAlphaComponent(0.5) : Palette.dim
        layer.cornerRadius = Layout.scale(16)
        layer.cornerCurve = .continuous

        chNumeral.text = numeral
        chNumeral.font = .systemFont(ofSize: Layout.scale(11), weight: .medium)
        chNumeral.textColor = locked ? Palette.ghost.withAlphaComponent(0.4) : Palette.ghost
        addSubview(chNumeral)

        chName.text = name.uppercased()
        chName.font = .systemFont(ofSize: Layout.scale(18), weight: .bold)
        chName.textColor = locked ? Palette.fog.withAlphaComponent(0.4) : Palette.paper
        addSubview(chName)

        grid.axis = .horizontal
        grid.distribution = .fillEqually
        grid.spacing = Layout.scale(8)
        addSubview(grid)

        for spec in stages {
            let btn = StageButton(spec: spec)
            btn.onTap = { [weak self] in self?.onStageTap?(spec) }
            grid.addArrangedSubview(btn)
        }

        if locked {
            lockOverlay.backgroundColor = Palette.void.withAlphaComponent(0.35)
            lockOverlay.layer.cornerRadius = Layout.scale(16)
            let icon = UILabel()
            icon.text = "🔒"
            icon.font = .systemFont(ofSize: Layout.scale(20))
            icon.textAlignment = .center
            lockOverlay.addSubview(icon)
            icon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: lockOverlay.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: lockOverlay.centerYAnchor),
            ])
            addSubview(lockOverlay)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let pad = Layout.scale(16)
        let w = bounds.width - pad*2

        chNumeral.frame = CGRect(x: pad, y: pad, width: w, height: Layout.scale(14))
        chName.frame = CGRect(x: pad, y: pad + Layout.scale(16), width: w, height: Layout.scale(24))

        let gridY = pad + Layout.scale(48)
        grid.frame = CGRect(x: pad, y: gridY, width: w, height: Layout.scale(54))
        lockOverlay.frame = bounds
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric,
               height: Layout.scale(16+14+16+24+8+54+16))
    }
}

// MARK: - Stage button dot

private final class StageButton: UIView {
    var onTap: (() -> Void)?
    private let spec: StageSpec
    private let numLabel = UILabel()
    private let starDot = UIView()

    init(spec: StageSpec) {
        self.spec = spec
        super.init(frame: .zero)

        let state = Vault.shared.state(for: spec.id)
        let unlocked = state.unlocked

        backgroundColor = unlocked ? Palette.mist : Palette.dim.withAlphaComponent(0.4)
        layer.cornerRadius = Layout.scale(10)
        layer.cornerCurve = .continuous

        if state.cleared { backgroundColor = Palette.paper.withAlphaComponent(0.12) }

        numLabel.text = "\(spec.id)"
        numLabel.font = .systemFont(ofSize: Layout.scale(14), weight: unlocked ? .semibold : .light)
        numLabel.textColor = unlocked ? Palette.paper : Palette.ghost
        numLabel.textAlignment = .center
        addSubview(numLabel)

        if state.cleared {
            starDot.backgroundColor = Palette.spark
            starDot.layer.cornerRadius = Layout.scale(2.5)
            addSubview(starDot)
        } else {
            starDot.isHidden = true
        }

        if unlocked {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        numLabel.frame = bounds
        if !starDot.isHidden {
            starDot.frame = CGRect(x: bounds.width - Layout.scale(10), y: Layout.scale(6),
                                   width: Layout.scale(5), height: Layout.scale(5))
        }
    }

    @objc private func tapped() {
        UIView.animate(withDuration: 0.08, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 1) { self.transform = .identity }
        }
        onTap?()
    }
}
