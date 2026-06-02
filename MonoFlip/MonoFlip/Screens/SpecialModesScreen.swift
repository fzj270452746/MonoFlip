import UIKit

// Daily challenge entry screen and Time Attack mode launcher.

final class SpecialModesScreen: UIViewController {

    private let titleLabel = UILabel()
    private let dailyCard = ModeCard()
    private let timeAttackCard = ModeCard()
    private let closeBtn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.void
        build()
    }

    private func build() {
        titleLabel.text = "MODES"
        titleLabel.font = .systemFont(ofSize: Layout.scale(13), weight: .medium)
        titleLabel.textColor = Palette.ghost
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = Palette.fog
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeBtn)

        // Daily puzzle card
        let dailySpec = DailyPuzzle.spec()
        let dailyDone = Vault.shared.isDailyCompleted(id: DailyPuzzle.todayID)
        dailyCard.configure(
            icon: "calendar",
            title: "DAILY PUZZLE",
            subtitle: dailyDone ? "Completed today ✓" : "New puzzle every day",
            accent: Palette.spark,
            dimmed: dailyDone
        )
        dailyCard.onTap = { [weak self] in
            guard let self else { return }
            let vc = PlayScreen(spec: dailySpec, mode: .daily)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        view.addSubview(dailyCard)

        // Time Attack card
        timeAttackCard.configure(
            icon: "timer",
            title: "TIME ATTACK",
            subtitle: "Solve as many as you can in 3 min",
            accent: Palette.warn,
            dimmed: false
        )
        timeAttackCard.onTap = { [weak self] in
            self?.startTimeAttack()
        }
        view.addSubview(timeAttackCard)
    }

    private func startTimeAttack() {
        // Start from stage 1 in time-attack mode
        guard let first = StageCatalog.all.first else { return }
        let vc = PlayScreen(spec: first, mode: .timeAttack(remaining: 180))
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let w = view.bounds.width
        let h = view.bounds.height

        closeBtn.frame = CGRect(x: Layout.scale(16), y: safe.top + Layout.scale(12),
                                width: 44, height: 44)
        titleLabel.frame = CGRect(x: 0, y: safe.top + Layout.scale(14),
                                  width: w, height: 28)

        let cardW = min(w - Layout.scale(40), 440)
        let cardX = (w - cardW) / 2
        let cardH = Layout.scale(110)
        let top = safe.top + Layout.scale(72)

        dailyCard.frame = CGRect(x: cardX, y: top, width: cardW, height: cardH)
        timeAttackCard.frame = CGRect(x: cardX, y: top + cardH + Layout.scale(16),
                                      width: cardW, height: cardH)

        // Center vertically if lots of room
        let totalContentH = cardH * 2 + Layout.scale(16)
        let idealTop = safe.top + (h - safe.top - safe.bottom - totalContentH) / 2
        if idealTop > top {
            dailyCard.frame.origin.y = idealTop
            timeAttackCard.frame.origin.y = idealTop + cardH + Layout.scale(16)
        }
    }

    @objc private func closeTapped() { dismiss(animated: true) }
}

// MARK: - Mode card

private final class ModeCard: UIView {
    var onTap: (() -> Void)?

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevron = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Palette.dim
        layer.cornerRadius = Layout.scale(16)
        layer.cornerCurve = .continuous

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = Palette.spark
        addSubview(iconView)

        titleLabel.font = .systemFont(ofSize: Layout.scale(16), weight: .bold)
        titleLabel.textColor = Palette.paper
        addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: Layout.scale(12), weight: .regular)
        subtitleLabel.textColor = Palette.fog
        subtitleLabel.numberOfLines = 2
        addSubview(subtitleLabel)

        chevron.text = "›"
        chevron.font = .systemFont(ofSize: Layout.scale(24), weight: .light)
        chevron.textColor = Palette.ghost
        addSubview(chevron)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(icon: String, title: String, subtitle: String,
                   accent: UIColor, dimmed: Bool) {
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = dimmed ? Palette.ghost : accent
        titleLabel.text = title
        titleLabel.textColor = dimmed ? Palette.fog : Palette.paper
        subtitleLabel.text = subtitle
        alpha = dimmed ? 0.7 : 1.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let pad = Layout.scale(20)
        let h = bounds.height
        let iconS = Layout.scale(32)
        iconView.frame = CGRect(x: pad, y: (h-iconS)/2, width: iconS, height: iconS)
        let textX = pad + iconS + Layout.scale(14)
        let textW = bounds.width - textX - Layout.scale(32)
        titleLabel.frame = CGRect(x: textX, y: h*0.25, width: textW, height: Layout.scale(20))
        subtitleLabel.frame = CGRect(x: textX, y: h*0.52, width: textW, height: Layout.scale(30))
        chevron.frame = CGRect(x: bounds.width - Layout.scale(30), y: 0,
                               width: Layout.scale(24), height: h)
    }

    @objc private func tapped() {
        UIView.animate(withDuration: 0.08, animations: { self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97) }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
                self.transform = .identity
            }
            self.onTap?()
        }
    }
}
