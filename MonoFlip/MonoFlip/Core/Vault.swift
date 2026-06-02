import Foundation

final class Vault {
    static let shared = Vault()
    private let key = "mf.progress.v1"
    private let dailyKey = "mf.daily.v1"
    private let taKey = "mf.timeattack.v1"
    private let achKey = "mf.achievements.v1"
    private let pointsKey = "mf.points.v1"
    private let missionKey = "mf.missions.v1"
    private let ownedThemesKey = "mf.themes.v1"

    private(set) var states: [Int: StageState] = [:]
    private var dailyCompleted: Set<Int> = []
    private(set) var timeAttackHighScore: Int = 0
    private(set) var timeAttackStagesThisSession: Int = 0

    // Achievements
    private(set) var unlockedAchievements: Set<String> = []
    private(set) var achievementPoints: Int = 0

    // Daily missions — keyed by "YYYYMMDD_missionId"
    private var missionProgress: [String: Int] = [:]
    private var missionCompleted: Set<String> = []

    // Owned themes
    private(set) var ownedThemeIDs: Set<String> = ["void"]

    private init() { load() }

    // MARK: Stage progress

    func state(for id: Int) -> StageState {
        states[id] ?? StageState(unlocked: id == 1, cleared: false, bestMoves: 0)
    }

    func record(stageID: Int, moves: Int) {
        var s = state(for: stageID)
        s.cleared = true
        s.unlocked = true
        if s.bestMoves == 0 || moves < s.bestMoves { s.bestMoves = moves }
        states[stageID] = s

        let next = stageID + 1
        if states[next] == nil {
            states[next] = StageState(unlocked: true, cleared: false, bestMoves: 0)
        } else {
            states[next]?.unlocked = true
        }
        save()
    }

    func isUnlocked(_ id: Int) -> Bool { state(for: id).unlocked }

    // MARK: Daily puzzle

    func isDailyCompleted(id: Int) -> Bool { dailyCompleted.contains(id) }

    func recordDailyCompleted(id: Int) {
        dailyCompleted.insert(id)
        if let data = try? JSONEncoder().encode(Array(dailyCompleted)) {
            UserDefaults.standard.set(data, forKey: dailyKey)
        }
    }

    // MARK: Time Attack

    func recordTimeAttackStage() {
        timeAttackStagesThisSession += 1
        if timeAttackStagesThisSession > timeAttackHighScore {
            timeAttackHighScore = timeAttackStagesThisSession
            UserDefaults.standard.set(timeAttackHighScore, forKey: taKey + ".hi")
        }
    }

    func resetTimeAttackSession() { timeAttackStagesThisSession = 0 }

    // MARK: Achievements

    func isAchievementUnlocked(_ id: String) -> Bool { unlockedAchievements.contains(id) }

    /// Returns the Achievement if newly unlocked (nil if already had it).
    @discardableResult
    func unlockAchievement(_ id: String) -> Achievement? {
        guard !unlockedAchievements.contains(id),
              let ach = Achievements.achievement(id: id) else { return nil }
        unlockedAchievements.insert(id)
        achievementPoints += ach.points
        saveAchievements()
        return ach
    }

    // MARK: Daily missions

    private func missionDayKey(_ missionID: String) -> String {
        let cal = Calendar.current; let now = Date()
        let y = cal.component(.year, from: now)
        let m = cal.component(.month, from: now)
        let d = cal.component(.day, from: now)
        return "\(y)\(String(format:"%02d",m))\(String(format:"%02d",d))_\(missionID)"
    }

    func missionProgress(id: String) -> Int {
        missionProgress[missionDayKey(id)] ?? 0
    }

    func isMissionCompleted(id: String) -> Bool {
        missionCompleted.contains(missionDayKey(id))
    }

    /// Increment mission counter. Returns the DailyMission if newly completed.
    @discardableResult
    func progressMission(id: String, by amount: Int = 1) -> DailyMission? {
        let dk = missionDayKey(id)
        guard !missionCompleted.contains(dk) else { return nil }
        guard let mission = DailyMissions.pool.first(where: { $0.id == id }) else { return nil }
        missionProgress[dk] = (missionProgress[dk] ?? 0) + amount
        if (missionProgress[dk] ?? 0) >= mission.targetCount {
            missionCompleted.insert(dk)
            achievementPoints += mission.points
            saveMissions()
            return mission
        }
        saveMissions()
        return nil
    }

    // MARK: Themes / Shop

    func ownsTheme(_ id: String) -> Bool { ownedThemeIDs.contains(id) }

    func purchaseTheme(_ id: String) -> Bool {
        guard let theme = ThemeStore.all.first(where: { $0.id == id }),
              !ownedThemeIDs.contains(id),
              achievementPoints >= theme.cost else { return false }
        achievementPoints -= theme.cost
        ownedThemeIDs.insert(id)
        saveAchievements()
        return true
    }

    // MARK: Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(states.mapKeys { String($0) }) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func saveAchievements() {
        UserDefaults.standard.set(Array(unlockedAchievements), forKey: achKey)
        UserDefaults.standard.set(achievementPoints, forKey: pointsKey)
        UserDefaults.standard.set(Array(ownedThemeIDs), forKey: ownedThemesKey)
    }

    private func saveMissions() {
        if let data = try? JSONEncoder().encode(missionProgress) {
            UserDefaults.standard.set(data, forKey: missionKey + ".progress")
        }
        UserDefaults.standard.set(Array(missionCompleted), forKey: missionKey + ".done")
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let raw = try? JSONDecoder().decode([String: StageState].self, from: data) {
            states = Dictionary(uniqueKeysWithValues: raw.compactMap { k, v in
                Int(k).map { ($0, v) }
            })
        }
        if states[1] == nil {
            states[1] = StageState(unlocked: true, cleared: false, bestMoves: 0)
        }
        if let data = UserDefaults.standard.data(forKey: dailyKey),
           let arr = try? JSONDecoder().decode([Int].self, from: data) {
            dailyCompleted = Set(arr)
        }
        timeAttackHighScore = UserDefaults.standard.integer(forKey: taKey + ".hi")

        // achievements
        let achArr = UserDefaults.standard.stringArray(forKey: achKey) ?? []
        unlockedAchievements = Set(achArr)
        achievementPoints = UserDefaults.standard.integer(forKey: pointsKey)

        // missions
        if let data = UserDefaults.standard.data(forKey: missionKey + ".progress"),
           let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            missionProgress = dict
        }
        let doneArr = UserDefaults.standard.stringArray(forKey: missionKey + ".done") ?? []
        missionCompleted = Set(doneArr)

        // themes
        let themeArr = UserDefaults.standard.stringArray(forKey: ownedThemesKey) ?? ["void"]
        ownedThemeIDs = Set(themeArr)
        if ownedThemeIDs.isEmpty { ownedThemeIDs.insert("void") }
    }
}

private extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}
