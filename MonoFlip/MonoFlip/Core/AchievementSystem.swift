import Foundation

// MARK: - Achievement definitions

struct Achievement: Codable {
    let id: String
    let title: String
    let desc: String
    let points: Int          // reward on first unlock
}

enum Achievements {
    static let all: [Achievement] = [
        // Progression
        Achievement(id: "first_clear",   title: "First Flip",      desc: "Clear your first stage.",          points: 10),
        Achievement(id: "ch1_done",      title: "Chapter I",        desc: "Complete all Chapter I stages.",   points: 20),
        Achievement(id: "ch5_done",      title: "Halfway There",    desc: "Complete Chapter V.",              points: 40),
        Achievement(id: "ch10_done",     title: "Endgame",          desc: "Complete all 50 stages.",          points: 100),
        // Stars
        Achievement(id: "star3_first",   title: "Par Buster",       desc: "Earn 3 stars on any stage.",       points: 15),
        Achievement(id: "star3_ten",     title: "Perfectionist",    desc: "Earn 3 stars on 10 stages.",       points: 50),
        // Daily
        Achievement(id: "daily_first",   title: "Daily Driver",     desc: "Complete your first daily puzzle.",points: 15),
        Achievement(id: "daily_seven",   title: "Week Streak",      desc: "Complete 7 daily puzzles.",        points: 60),
        Achievement(id: "daily_thirty",  title: "Devoted",          desc: "Complete 30 daily puzzles.",       points: 150),
        // Time Attack
        Achievement(id: "ta_first",      title: "Rush Hour",        desc: "Complete a Time Attack session.",  points: 20),
        Achievement(id: "ta_ten",        title: "Speed Demon",      desc: "Clear 10 stages in one TA run.",   points: 60),
        Achievement(id: "ta_twenty",     title: "Unstoppable",      desc: "Clear 20 stages in one TA run.",   points: 120),
        // Misc
        Achievement(id: "undo_never",    title: "No Regrets",       desc: "Clear a stage without undo.",      points: 25),
        Achievement(id: "moves_exact",   title: "Surgeon",          desc: "Clear a stage exactly at par.",    points: 30),
        Achievement(id: "themer",        title: "Style Icon",       desc: "Unlock a skin.",                   points: 20),
    ]

    static func achievement(id: String) -> Achievement? { all.first { $0.id == id } }
}

// MARK: - Daily missions

struct DailyMission: Codable {
    let id: String
    let title: String
    let desc: String
    let points: Int
    let targetCount: Int
}

enum DailyMissions {
    // 3 missions rotate daily based on date seed
    static let pool: [DailyMission] = [
        DailyMission(id: "play3",      title: "Warm Up",      desc: "Play 3 stages.",            points: 10, targetCount: 3),
        DailyMission(id: "play5",      title: "On a Roll",    desc: "Play 5 stages.",            points: 15, targetCount: 5),
        DailyMission(id: "clear3",     title: "Solver",       desc: "Clear 3 stages.",           points: 15, targetCount: 3),
        DailyMission(id: "clear5",     title: "Grinder",      desc: "Clear 5 stages.",           points: 25, targetCount: 5),
        DailyMission(id: "daily_do",   title: "Daily Dose",   desc: "Complete daily puzzle.",    points: 20, targetCount: 1),
        DailyMission(id: "ta_do",      title: "Attack Mode",  desc: "Start a Time Attack.",      points: 15, targetCount: 1),
        DailyMission(id: "undo3",      title: "Backtrack",    desc: "Undo 3 times.",             points: 8,  targetCount: 3),
        DailyMission(id: "star3_one",  title: "Par Hunter",   desc: "Earn 3 stars on any stage.",points: 20, targetCount: 1),
        DailyMission(id: "nohint",     title: "Solo",         desc: "Clear a stage without hint.",points: 12, targetCount: 1),
        DailyMission(id: "restart0",   title: "First Try",    desc: "Clear a stage without restart.",points: 15, targetCount: 1),
    ]

    static func todaysMissions() -> [DailyMission] {
        // date-seeded shuffle, pick 3
        let cal = Calendar.current
        let now = Date()
        let seed = UInt64(cal.component(.year, from: now)) * 10000
               + UInt64(cal.component(.month, from: now)) * 100
               + UInt64(cal.component(.day, from: now))
        var state = seed ^ 0xABCDEF1234567890
        func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state >> 33
        }
        var indices = Array(0..<pool.count)
        for i in stride(from: indices.count - 1, through: 1, by: -1) {
            let j = Int(next() % UInt64(i + 1))
            indices.swapAt(i, j)
        }
        return Array(indices.prefix(3).map { pool[$0] })
    }
}
