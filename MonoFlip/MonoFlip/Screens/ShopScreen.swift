import UIKit

final class ShopScreen: UIViewController {

    private let scrollView = UIScrollView()
    private let grid = UIStackView()
    private let closeBtn = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let pointsBadge = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.void
        build()
        reload()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged),
                                               name: .themeDidChange, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func build() {
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = Palette.fog
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeBtn)

        titleLabel.text = "SKINS"
        titleLabel.font = .systemFont(ofSize: Layout.scale(13), weight: .medium)
        titleLabel.textColor = Palette.ghost
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        pointsBadge.font = .monospacedDigitSystemFont(ofSize: Layout.scale(13), weight: .semibold)
        pointsBadge.textColor = Palette.spark
        pointsBadge.textAlignment = .right
        view.addSubview(pointsBadge)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        grid.axis = .vertical
        grid.spacing = Layout.scale(12)
        grid.alignment = .fill
        scrollView.addSubview(grid)
    }

    private func reload() {
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pointsBadge.text = "⬡ \(Vault.shared.achievementPoints) pts"

        let note = UILabel()
        note.text = "Earn points by completing daily missions and achievements."
        note.font = .systemFont(ofSize: Layout.scale(11), weight: .regular)
        note.textColor = Palette.ghost
        note.textAlignment = .center
        note.numberOfLines = 2
        grid.addArrangedSubview(note)

        for theme in ThemeStore.all {
            let owned = Vault.shared.ownsTheme(theme.id)
            let active = ThemeStore.current.id == theme.id
            let card = ThemeCard(theme: theme, owned: owned, active: active)
            card.onAction = { [weak self] in self?.handleAction(theme: theme) }
            grid.addArrangedSubview(card)
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func handleAction(theme: Theme) {
        if Vault.shared.ownsTheme(theme.id) {
            ThemeStore.apply(theme)
            reload()
            return
        }
        // Try to purchase
        if Vault.shared.achievementPoints < theme.cost {
            OverlayPanel.show(on: self,
                title: "Not Enough Points",
                body: "You need \(theme.cost) pts to unlock \(theme.name).\nCurrently: \(Vault.shared.achievementPoints) pts",
                actions: [.init(title: "OK", style: .primary) {}])
            return
        }
        OverlayPanel.show(on: self,
            title: "Unlock \(theme.name)?",
            body: "Costs \(theme.cost) pts. You have \(Vault.shared.achievementPoints) pts.",
            actions: [
                .init(title: "Unlock", style: .primary) { [weak self] in
                    if Vault.shared.purchaseTheme(theme.id) {
                        ThemeStore.apply(theme)
                        Vault.shared.unlockAchievement("themer")
                        self?.reload()
                    }
                },
                .init(title: "Cancel", style: .secondary) {},
            ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let w = view.bounds.width
        let h = view.bounds.height

        closeBtn.frame = CGRect(x: Layout.scale(16), y: safe.top + Layout.scale(12), width: 44, height: 44)
        titleLabel.frame = CGRect(x: 0, y: safe.top + Layout.scale(16), width: w, height: 28)
        pointsBadge.frame = CGRect(x: w - Layout.scale(120), y: safe.top + Layout.scale(16),
                                   width: Layout.scale(110), height: 28)

        let scrollTop = safe.top + Layout.scale(60)
        scrollView.frame = CGRect(x: 0, y: scrollTop, width: w, height: h - scrollTop)

        let pad = Layout.scale(20)
        let cw = min(w - pad*2, 440)
        let cx = (w - cw) / 2
        let fittedH = grid.systemLayoutSizeFitting(
            CGSize(width: cw, height: UIView.layoutFittingCompressedSize.height)).height
        grid.frame = CGRect(x: cx, y: pad, width: cw, height: fittedH)
        scrollView.contentSize = CGSize(width: w, height: fittedH + pad * 2)
    }

    @objc private func close() { dismiss(animated: true) }
    @objc private func themeChanged() { reload() }
}

// MARK: - Theme preview card

private final class ThemeCard: UIView {
    var onAction: (() -> Void)?

    private let previewRow = UIView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let actionBtn = UIButton(type: .system)

    init(theme: Theme, owned: Bool, active: Bool) {
        super.init(frame: .zero)

        backgroundColor = UIColor.hex(theme.dimHex)
        layer.cornerRadius = Layout.scale(16)
        layer.cornerCurve = .continuous
        if active {
            layer.borderWidth = 2
            layer.borderColor = UIColor.hex(theme.accentHex).cgColor
        }

        // Color swatch row
        let litSwatch = UIView()
        litSwatch.backgroundColor = UIColor.hex(theme.litHex)
        litSwatch.layer.cornerRadius = Layout.scale(6)
        previewRow.addSubview(litSwatch)

        let unlitSwatch = UIView()
        unlitSwatch.backgroundColor = UIColor.hex(theme.unlitHex)
        unlitSwatch.layer.borderColor = UIColor.hex(theme.mistHex).cgColor
        unlitSwatch.layer.borderWidth = 1
        unlitSwatch.layer.cornerRadius = Layout.scale(6)
        previewRow.addSubview(unlitSwatch)

        let accentSwatch = UIView()
        accentSwatch.backgroundColor = UIColor.hex(theme.accentHex)
        accentSwatch.layer.cornerRadius = Layout.scale(6)
        previewRow.addSubview(accentSwatch)

        addSubview(previewRow)

        nameLabel.text = theme.name
        nameLabel.font = .systemFont(ofSize: Layout.scale(16), weight: .bold)
        nameLabel.textColor = UIColor.hex(theme.litHex)
        addSubview(nameLabel)

        if active {
            statusLabel.text = "ACTIVE"
            statusLabel.textColor = UIColor.hex(theme.accentHex)
        } else if owned {
            statusLabel.text = "OWNED"
            statusLabel.textColor = UIColor(white: 0.55, alpha: 1)
        } else {
            statusLabel.text = "\(theme.cost) pts"
            statusLabel.textColor = UIColor.hex(theme.accentHex)
        }
        statusLabel.font = .systemFont(ofSize: Layout.scale(11), weight: .medium)
        addSubview(statusLabel)

        if active {
            actionBtn.setTitle("Selected", for: .normal)
            actionBtn.isEnabled = false
            actionBtn.alpha = 0.4
        } else if owned {
            actionBtn.setTitle("Apply", for: .normal)
        } else {
            actionBtn.setTitle("Unlock", for: .normal)
        }
        actionBtn.titleLabel?.font = .systemFont(ofSize: Layout.scale(13), weight: .semibold)
        actionBtn.tintColor = UIColor.hex(theme.accentHex)
        actionBtn.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        addSubview(actionBtn)

        for v in [previewRow, nameLabel, statusLabel, actionBtn, litSwatch, unlitSwatch, accentSwatch] {
            v.translatesAutoresizingMaskIntoConstraints = false
        }

        let pad = Layout.scale(16)
        let swatchS = Layout.scale(20)
        NSLayoutConstraint.activate([
            previewRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            previewRow.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            previewRow.widthAnchor.constraint(equalToConstant: swatchS*3 + Layout.scale(6)*2),
            previewRow.heightAnchor.constraint(equalToConstant: swatchS),

            litSwatch.leadingAnchor.constraint(equalTo: previewRow.leadingAnchor),
            litSwatch.centerYAnchor.constraint(equalTo: previewRow.centerYAnchor),
            litSwatch.widthAnchor.constraint(equalToConstant: swatchS),
            litSwatch.heightAnchor.constraint(equalToConstant: swatchS),

            unlitSwatch.leadingAnchor.constraint(equalTo: litSwatch.trailingAnchor, constant: Layout.scale(6)),
            unlitSwatch.centerYAnchor.constraint(equalTo: previewRow.centerYAnchor),
            unlitSwatch.widthAnchor.constraint(equalToConstant: swatchS),
            unlitSwatch.heightAnchor.constraint(equalToConstant: swatchS),

            accentSwatch.leadingAnchor.constraint(equalTo: unlitSwatch.trailingAnchor, constant: Layout.scale(6)),
            accentSwatch.centerYAnchor.constraint(equalTo: previewRow.centerYAnchor),
            accentSwatch.widthAnchor.constraint(equalToConstant: swatchS),
            accentSwatch.heightAnchor.constraint(equalToConstant: swatchS),

            nameLabel.leadingAnchor.constraint(equalTo: previewRow.trailingAnchor, constant: Layout.scale(14)),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            nameLabel.trailingAnchor.constraint(equalTo: actionBtn.leadingAnchor, constant: -8),

            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),

            actionBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            actionBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionBtn.widthAnchor.constraint(equalToConstant: Layout.scale(70)),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func tapped() { onAction?() }
}
