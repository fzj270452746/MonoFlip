import UIKit

// Custom overlay-style dialog replacing system alerts.
// Slides up from bottom with a blur backing card.

final class OverlayPanel: UIView {
    struct Action {
        let title: String
        let style: Style
        let handler: () -> Void

        enum Style { case primary, secondary, destructive }
    }

    private let backdrop = UIView()
    private let card = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private var buttons: [UIButton] = []

    static func show(on vc: UIViewController,
                     title: String,
                     body: String,
                     actions: [Action]) {
        let panel = OverlayPanel()
        panel.build(title: title, body: body, actions: actions)
        vc.view.addSubview(panel)
        panel.frame = vc.view.bounds
        panel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        panel.animateIn()
    }

    private func build(title: String, body: String, actions: [Action]) {
        // backdrop
        backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backdrop.frame = bounds
        backdrop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backdrop)
        let tap = UITapGestureRecognizer(target: self, action: #selector(backdropTapped))
        backdrop.addGestureRecognizer(tap)

        // card
        card.backgroundColor = Palette.dim
        card.layer.cornerRadius = Layout.scale(20)
        card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.clipsToBounds = true
        addSubview(card)

        // title
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Layout.scale(22), weight: .bold)
        titleLabel.textColor = Palette.paper
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        card.addSubview(titleLabel)

        // body
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: Layout.scale(14), weight: .regular)
        bodyLabel.textColor = Palette.fog
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        card.addSubview(bodyLabel)

        // buttons
        buttons = actions.map { action in
            let btn = MonoButton(title: action.title, style: action.style)
            btn.addAction(UIAction { [weak self] _ in
                self?.animateOut { action.handler() }
            }, for: .touchUpInside)
            card.addSubview(btn)
            return btn
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backdrop.frame = bounds

        let w = min(bounds.width, 480)  // cap for iPad
        let pad = Layout.scale(24)
        let btnH = Layout.scale(52)
        let spacing = Layout.scale(12)

        // measure content
        let maxW = w - pad*2
        let tSize = titleLabel.sizeThatFits(CGSize(width: maxW, height: 200))
        let bSize = bodyLabel.sizeThatFits(CGSize(width: maxW, height: 200))
        let btnCount = CGFloat(buttons.count)
        let totalH = pad + tSize.height + spacing + bSize.height
                   + spacing*2 + btnH*btnCount + spacing*(btnCount-1) + pad
                   + safeAreaInsets.bottom

        let cardY = bounds.height - totalH
        card.frame = CGRect(x: (bounds.width-w)/2, y: cardY, width: w, height: totalH)

        var y = pad
        titleLabel.frame = CGRect(x: pad, y: y, width: maxW, height: tSize.height)
        y += tSize.height + spacing
        bodyLabel.frame = CGRect(x: pad, y: y, width: maxW, height: bSize.height)
        y += bSize.height + spacing*2
        for btn in buttons {
            btn.frame = CGRect(x: pad, y: y, width: maxW, height: btnH)
            y += btnH + spacing
        }
    }

    private func animateIn() {
        backdrop.alpha = 0
        card.transform = CGAffineTransform(translationX: 0, y: 300)
        UIView.animate(withDuration: 0.38, delay: 0, usingSpringWithDamping: 0.82,
                       initialSpringVelocity: 0.5) {
            self.backdrop.alpha = 1
            self.card.transform = .identity
        }
    }

    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.22) {
            self.backdrop.alpha = 0
            self.card.transform = CGAffineTransform(translationX: 0, y: 300)
        } completion: { _ in
            self.removeFromSuperview()
            completion()
        }
    }

    @objc private func backdropTapped() {}   // swallow — modal
}

// MARK: - Mono-style button

final class MonoButton: UIButton {
    init(title: String, style: OverlayPanel.Action.Style) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: Layout.scale(16), weight: .semibold)
        layer.cornerRadius = Layout.scale(12)
        layer.cornerCurve = .continuous

        switch style {
        case .primary:
            backgroundColor = Palette.paper
            setTitleColor(Palette.ink, for: .normal)
        case .secondary:
            backgroundColor = Palette.mist
            setTitleColor(Palette.paper, for: .normal)
        case .destructive:
            backgroundColor = Palette.warn.withAlphaComponent(0.2)
            setTitleColor(Palette.warn, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = Palette.warn.withAlphaComponent(0.5).cgColor
        }

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) { self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }
    }
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
            self.transform = .identity
        }
    }
}
