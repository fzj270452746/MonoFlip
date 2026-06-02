import UIKit

final class ProfileScreen: UIViewController {

    private let segControl = UISegmentedControl(items: ["MISSIONS", "ACHIEVEMENTS"])
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let closeBtn = UIButton(type: .system)
    private let pointsBadge = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.void
        build()
        reload()
    }

    private func build() {
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = Palette.fog
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeBtn)

        // Points badge top-right
        pointsBadge.font = .monospacedDigitSystemFont(ofSize: Layout.scale(13), weight: .semibold)
        pointsBadge.textColor = Palette.spark
        pointsBadge.textAlignment = .right
        view.addSubview(pointsBadge)

        segControl.selectedSegmentIndex = 0
        segControl.addTarget(self, action: #selector(segChanged), for: .valueChanged)
        segControl.selectedSegmentTintColor = Palette.mist
        segControl.setTitleTextAttributes([.foregroundColor: Palette.fog], for: .normal)
        segControl.setTitleTextAttributes([.foregroundColor: Palette.paper], for: .selected)
        view.addSubview(segControl)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = Layout.scale(12)
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
    }

    private func reload() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pointsBadge.text = "⬡ \(Vault.shared.achievementPoints) pts"

        if segControl.selectedSegmentIndex == 0 {
            buildMissions()
        } else {
            buildAchievements()
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    // MARK: Missions tab

    private func buildMissions() {
        let missions = DailyMissions.todaysMissions()

        let headerL = sectionHeader("TODAY'S MISSIONS")
        contentStack.addArrangedSubview(headerL)

        for m in missions {
            let progress = Vault.shared.missionProgress(id: m.id)
            let done = Vault.shared.isMissionCompleted(id: m.id)
            let card = MissionCard(mission: m, progress: progress, completed: done)
            contentStack.addArrangedSubview(card)
        }

        // padding
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: Layout.scale(20)).isActive = true
        contentStack.addArrangedSubview(spacer)

        let infoL = UILabel()
        infoL.text = "Missions reset daily. Complete them to earn achievement points."
        infoL.font = .systemFont(ofSize: Layout.scale(11), weight: .regular)
        infoL.textColor = Palette.ghost
        infoL.textAlignment = .center
        infoL.numberOfLines = 2
        contentStack.addArrangedSubview(infoL)
    }

    // MARK: Achievements tab

    private func buildAchievements() {
        let unlocked = Vault.shared.unlockedAchievements
        let headerL = sectionHeader("ACHIEVEMENTS (\(unlocked.count)/\(Achievements.all.count))")
        contentStack.addArrangedSubview(headerL)

        for ach in Achievements.all {
            let done = unlocked.contains(ach.id)
            let card = AchievementCard(achievement: ach, unlocked: done)
            contentStack.addArrangedSubview(card)
        }
    }

    private func sectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: Layout.scale(11), weight: .medium)
        l.textColor = Palette.ghost
        l.textAlignment = .center
        return l
    }

    // MARK: Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let w = view.bounds.width
        let h = view.bounds.height

        closeBtn.frame = CGRect(x: Layout.scale(16), y: safe.top + Layout.scale(12), width: 44, height: 44)
        pointsBadge.frame = CGRect(x: w - Layout.scale(120), y: safe.top + Layout.scale(16),
                                   width: Layout.scale(110), height: 28)

        let segY = safe.top + Layout.scale(60)
        segControl.frame = CGRect(x: Layout.scale(20), y: segY,
                                  width: w - Layout.scale(40), height: 32)

        let scrollTop = segY + 48
        scrollView.frame = CGRect(x: 0, y: scrollTop, width: w, height: h - scrollTop)

        let pad = Layout.scale(20)
        let cw = min(w - pad*2, 440)
        let cx = (w - cw) / 2
        let fittedH = contentStack.systemLayoutSizeFitting(
            CGSize(width: cw, height: UIView.layoutFittingCompressedSize.height)).height
        contentStack.frame = CGRect(x: cx, y: pad, width: cw, height: fittedH)
        scrollView.contentSize = CGSize(width: w, height: fittedH + pad * 2)
    }

    @objc private func segChanged() { reload() }
    @objc private func close() { dismiss(animated: true) }
}

// MARK: - Mission card

private final class MissionCard: UIView {
    init(mission: DailyMission, progress: Int, completed: Bool) {
        super.init(frame: .zero)
        backgroundColor = Palette.dim
        layer.cornerRadius = Layout.scale(12)
        layer.cornerCurve = .continuous
        alpha = completed ? 0.6 : 1.0

        let iconV = UIImageView(image: UIImage(systemName: completed ? "checkmark.circle.fill" : "circle"))
        iconV.tintColor = completed ? Palette.spark : Palette.ghost
        iconV.contentMode = .scaleAspectFit
        addSubview(iconV)

        let titleL = UILabel()
        titleL.text = mission.title
        titleL.font = .systemFont(ofSize: Layout.scale(14), weight: .semibold)
        titleL.textColor = Palette.paper
        addSubview(titleL)

        let descL = UILabel()
        descL.text = mission.desc
        descL.font = .systemFont(ofSize: Layout.scale(11), weight: .regular)
        descL.textColor = Palette.fog
        addSubview(descL)

        let ptsL = UILabel()
        ptsL.text = "+\(mission.points) pts"
        ptsL.font = .systemFont(ofSize: Layout.scale(11), weight: .medium)
        ptsL.textColor = Palette.spark
        ptsL.textAlignment = .right
        addSubview(ptsL)

        // progress bar (only if not completed and targetCount > 1)
        if !completed && mission.targetCount > 1 {
            let track = UIView()
            track.backgroundColor = Palette.mist
            track.layer.cornerRadius = 2
            addSubview(track)

            let fill = UIView()
            let pct = min(CGFloat(progress) / CGFloat(mission.targetCount), 1.0)
            fill.backgroundColor = Palette.spark
            fill.layer.cornerRadius = 2
            track.addSubview(fill)

            for v in [iconV, titleL, descL, ptsL, track, fill] { v.translatesAutoresizingMaskIntoConstraints = false }
            let pad = Layout.scale(14)
            let iconS = Layout.scale(22)
            NSLayoutConstraint.activate([
                iconV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
                iconV.topAnchor.constraint(equalTo: topAnchor, constant: pad),
                iconV.widthAnchor.constraint(equalToConstant: iconS),
                iconV.heightAnchor.constraint(equalToConstant: iconS),

                titleL.leadingAnchor.constraint(equalTo: iconV.trailingAnchor, constant: Layout.scale(10)),
                titleL.topAnchor.constraint(equalTo: topAnchor, constant: pad),
                titleL.trailingAnchor.constraint(equalTo: ptsL.leadingAnchor, constant: -8),

                descL.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
                descL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 2),
                descL.trailingAnchor.constraint(equalTo: titleL.trailingAnchor),

                ptsL.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
                ptsL.centerYAnchor.constraint(equalTo: iconV.centerYAnchor),
                ptsL.widthAnchor.constraint(equalToConstant: Layout.scale(60)),

                track.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
                track.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
                track.topAnchor.constraint(equalTo: descL.bottomAnchor, constant: Layout.scale(8)),
                track.heightAnchor.constraint(equalToConstant: 4),
                track.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),

                fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
                fill.topAnchor.constraint(equalTo: track.topAnchor),
                fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
                fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: pct),
            ])
        } else {
            for v in [iconV, titleL, descL, ptsL] { v.translatesAutoresizingMaskIntoConstraints = false }
            let pad = Layout.scale(14)
            let iconS = Layout.scale(22)
            NSLayoutConstraint.activate([
                iconV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
                iconV.topAnchor.constraint(equalTo: topAnchor, constant: pad),
                iconV.widthAnchor.constraint(equalToConstant: iconS),
                iconV.heightAnchor.constraint(equalToConstant: iconS),

                titleL.leadingAnchor.constraint(equalTo: iconV.trailingAnchor, constant: Layout.scale(10)),
                titleL.topAnchor.constraint(equalTo: topAnchor, constant: pad),
                titleL.trailingAnchor.constraint(equalTo: ptsL.leadingAnchor, constant: -8),

                descL.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
                descL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 2),
                descL.trailingAnchor.constraint(equalTo: titleL.trailingAnchor),
                descL.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),

                ptsL.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
                ptsL.centerYAnchor.constraint(equalTo: iconV.centerYAnchor),
                ptsL.widthAnchor.constraint(equalToConstant: Layout.scale(60)),
            ])
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Achievement card

private final class AchievementCard: UIView {
    init(achievement: Achievement, unlocked: Bool) {
        super.init(frame: .zero)
        backgroundColor = Palette.dim
        layer.cornerRadius = Layout.scale(12)
        layer.cornerCurve = .continuous
        alpha = unlocked ? 1.0 : 0.4

        let iconV = UIImageView(image: UIImage(systemName: unlocked ? "rosette" : "lock.fill"))
        iconV.tintColor = unlocked ? Palette.spark : Palette.ghost
        iconV.contentMode = .scaleAspectFit
        addSubview(iconV)

        let titleL = UILabel()
        titleL.text = achievement.title
        titleL.font = .systemFont(ofSize: Layout.scale(13), weight: .semibold)
        titleL.textColor = unlocked ? Palette.paper : Palette.fog
        addSubview(titleL)

        let descL = UILabel()
        descL.text = achievement.desc
        descL.font = .systemFont(ofSize: Layout.scale(11), weight: .regular)
        descL.textColor = Palette.ghost
        descL.numberOfLines = 2
        addSubview(descL)

        let ptsL = UILabel()
        ptsL.text = "+\(achievement.points)"
        ptsL.font = .systemFont(ofSize: Layout.scale(11), weight: .medium)
        ptsL.textColor = unlocked ? Palette.spark : Palette.ghost
        ptsL.textAlignment = .right
        addSubview(ptsL)

        for v in [iconV, titleL, descL, ptsL] { v.translatesAutoresizingMaskIntoConstraints = false }
        let pad = Layout.scale(14)
        let iconS = Layout.scale(20)
        NSLayoutConstraint.activate([
            iconV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            iconV.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            iconV.widthAnchor.constraint(equalToConstant: iconS),
            iconV.heightAnchor.constraint(equalToConstant: iconS),

            titleL.leadingAnchor.constraint(equalTo: iconV.trailingAnchor, constant: Layout.scale(10)),
            titleL.topAnchor.constraint(equalTo: topAnchor, constant: pad),
            titleL.trailingAnchor.constraint(equalTo: ptsL.leadingAnchor, constant: -8),

            descL.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
            descL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 2),
            descL.trailingAnchor.constraint(equalTo: titleL.trailingAnchor),
            descL.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -pad),

            ptsL.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
            ptsL.centerYAnchor.constraint(equalTo: iconV.centerYAnchor),
            ptsL.widthAnchor.constraint(equalToConstant: Layout.scale(48)),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
