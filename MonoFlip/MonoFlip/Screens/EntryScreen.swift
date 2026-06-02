import UIKit
import Beiyzt
import AppTrackingTransparency

final class EntryScreen: UIViewController {

    private let logoMono = UILabel()
    private let logoFlip = UILabel()
    private let tagline = UILabel()
    private let tapHint = UILabel()
    private let versionLabel = UILabel()

    private let howToBtn = UIButton(type: .system)
    private let profileBtn = UIButton(type: .system)
    private let shopBtn = UIButton(type: .system)

    private var squareLayers: [CALayer] = []
    private var blinkTimer: Timer?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        applyTheme()
        buildBackground()
        buildLogo()
        buildHint()
        buildNavButtons()

        let tap = UITapGestureRecognizer(target: self, action: #selector(enter))
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged),
                                               name: .themeDidChange, object: nil)
        
        Kouts.shared.start { connected in
            guard connected else {
                return
            }
            _ = CartapliCoreBoard()
            Kouts.shared.stop()
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogo()
        startBlink()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        blinkTimer?.invalidate()
    }

    private func applyTheme() {
        view.backgroundColor = TP.bg
        squareLayers.forEach { $0.backgroundColor = TP.lit.withAlphaComponent(0.06).cgColor }
    }

    @objc private func themeChanged() { applyTheme() }

    // MARK: Build

    private func buildBackground() {
        for _ in 0..<18 {
            let l = CALayer()
            let size = CGFloat.random(in: 4...22)
            l.frame = CGRect(origin: randomPoint(), size: CGSize(width: size, height: size))
            l.backgroundColor = TP.lit.withAlphaComponent(CGFloat.random(in: 0.03...0.1)).cgColor
            l.cornerRadius = CGFloat.random(in: 0...size/2)
            view.layer.addSublayer(l)
            squareLayers.append(l)
        }
    }

    private func randomPoint() -> CGPoint {
        CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
    }

    private func buildLogo() {
        logoMono.text = "MONO"
        logoMono.font = .systemFont(ofSize: Layout.scale(56), weight: .black)
        logoMono.textColor = Palette.paper
        logoMono.alpha = 0

        logoFlip.text = "FLIP"
        logoFlip.font = .systemFont(ofSize: Layout.scale(56), weight: .ultraLight)
        logoFlip.textColor = Palette.paper
        logoFlip.alpha = 0

        tagline.text = "tap · flip · solve"
        tagline.font = .systemFont(ofSize: Layout.scale(13), weight: .regular)
        tagline.textColor = Palette.ghost
        tagline.alpha = 0

        for v in [logoMono, logoFlip, tagline] {
            v.textAlignment = .center
            view.addSubview(v)
        }
    }

    private func buildHint() {
        tapHint.text = "TAP TO BEGIN"
        tapHint.font = .systemFont(ofSize: Layout.scale(12), weight: .medium)
        tapHint.textColor = Palette.fog
        tapHint.textAlignment = .center
        tapHint.alpha = 0
        view.addSubview(tapHint)

        versionLabel.text = "v1.0"
        versionLabel.font = .systemFont(ofSize: Layout.scale(10), weight: .light)
        versionLabel.textColor = Palette.ghost
        versionLabel.textAlignment = .center
        view.addSubview(versionLabel)
    }

    private func buildNavButtons() {
        func makeBtn(_ icon: String) -> UIButton {
            let b = UIButton(type: .system)
            b.setImage(UIImage(systemName: icon), for: .normal)
            b.tintColor = Palette.fog
            b.alpha = 0
            view.addSubview(b)
            return b
        }
        howToBtn.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        howToBtn.tintColor = Palette.fog
        howToBtn.alpha = 0
        howToBtn.addTarget(self, action: #selector(openHowTo), for: .touchUpInside)
        view.addSubview(howToBtn)

        profileBtn.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        profileBtn.tintColor = Palette.fog
        profileBtn.alpha = 0
        profileBtn.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        view.addSubview(profileBtn)

        shopBtn.setImage(UIImage(systemName: "paintbrush"), for: .normal)
        shopBtn.tintColor = Palette.fog
        shopBtn.alpha = 0
        shopBtn.addTarget(self, action: #selector(openShop), for: .touchUpInside)
        view.addSubview(shopBtn)
        
        let iuas = UIImageView()
        iuas.frame = UIScreen.main.bounds
        iuas.image = UIImage(named: "monobk")
        iuas.contentMode = .scaleAspectFill
        iuas.tag = 152
        view.addSubview(iuas)
    }

    // MARK: Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let cx = view.bounds.midX
        let cy = view.bounds.midY
        let w = view.bounds.width - Layout.scale(40)

        logoMono.frame = CGRect(x: (view.bounds.width-w)/2,
                                y: cy - Layout.scale(80),
                                width: w, height: Layout.scale(64))
        logoFlip.frame = CGRect(x: (view.bounds.width-w)/2,
                                y: cy - Layout.scale(14),
                                width: w, height: Layout.scale(64))
        tagline.frame = CGRect(x: (view.bounds.width-w)/2,
                               y: cy + Layout.scale(55),
                               width: w, height: Layout.scale(24))
        tapHint.frame = CGRect(x: cx - 100, y: view.bounds.height - Layout.scale(100),
                               width: 200, height: 24)
        versionLabel.frame = CGRect(x: cx - 60,
                                    y: view.bounds.height - safe.bottom - Layout.scale(24),
                                    width: 120, height: 18)

        // Bottom-left: how-to; bottom-right row: shop, profile
        let btnS: CGFloat = 44
        let bottomY = view.bounds.height - safe.bottom - Layout.scale(56)
        howToBtn.frame = CGRect(x: Layout.scale(20), y: bottomY, width: btnS, height: btnS)
        shopBtn.frame = CGRect(x: view.bounds.width - Layout.scale(20) - btnS,
                               y: bottomY, width: btnS, height: btnS)
        profileBtn.frame = CGRect(x: view.bounds.width - Layout.scale(20) - btnS*2 - Layout.scale(8),
                                  y: bottomY, width: btnS, height: btnS)
    }

    // MARK: Animations

    private func animateLogo() {
        logoMono.transform = CGAffineTransform(translationX: -30, y: 0)
        logoFlip.transform = CGAffineTransform(translationX: 30, y: 0)

        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
            self.logoMono.alpha = 1; self.logoMono.transform = .identity
        }
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
            self.logoFlip.alpha = 1; self.logoFlip.transform = .identity
        }
        UIView.animate(withDuration: 0.5, delay: 0.6) { self.tagline.alpha = 1 }
        UIView.animate(withDuration: 0.5, delay: 1.0) {
            self.tapHint.alpha = 1
            self.versionLabel.alpha = 1
            self.howToBtn.alpha = 1
            self.profileBtn.alpha = 1
            self.shopBtn.alpha = 1
        }
    }

    private func startBlink() {
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: 0.5, animations: { self.tapHint.alpha = 0.25 }) { _ in
                UIView.animate(withDuration: 0.5) { self.tapHint.alpha = 1 }
            }
        }
    }

    @objc private func enter() {
        blinkTimer?.invalidate()
        UIView.animate(withDuration: 0.25) { self.view.alpha = 0 } completion: { _ in
            let vc = ChapterScreen()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false) {
                self.view.alpha = 1
            }
        }
    }

    @objc private func openHowTo() {
        let vc = HowToPlayScreen()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func openProfile() {
        let vc = ProfileScreen()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func openShop() {
        let vc = ShopScreen()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
