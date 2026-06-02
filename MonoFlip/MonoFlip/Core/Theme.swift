import UIKit

struct Theme: Codable, Equatable {
    let id: String
    let name: String
    // encoded as hex strings for Codable
    let bgHex: String
    let dimHex: String
    let mistHex: String
    let litHex: String    // tile lit color
    let unlitHex: String  // tile unlit color
    let accentHex: String // star/spark color
    let cost: Int         // 0 = free
}

enum ThemeStore {
    static let all: [Theme] = [
        Theme(id: "void",     name: "VOID",
              bgHex: "0F0F0F", dimHex: "1E1E1E", mistHex: "2D2D2D",
              litHex: "F5F5F5", unlitHex: "1E1E1E", accentHex: "99FFCC", cost: 0),
        Theme(id: "ember",    name: "EMBER",
              bgHex: "110A00", dimHex: "211400", mistHex: "3A2200",
              litHex: "FFD080", unlitHex: "211400", accentHex: "FF8C42", cost: 80),
        Theme(id: "glacier",  name: "GLACIER",
              bgHex: "060D14", dimHex: "0D1E2C", mistHex: "153145",
              litHex: "B8E8FF", unlitHex: "0D1E2C", accentHex: "44CFFF", cost: 80),
        Theme(id: "sakura",   name: "SAKURA",
              bgHex: "140A0F", dimHex: "241018", mistHex: "3D1A28",
              litHex: "FFB8D0", unlitHex: "241018", accentHex: "FF6EA3", cost: 120),
        Theme(id: "matrix",   name: "MATRIX",
              bgHex: "000800", dimHex: "001400", mistHex: "002200",
              litHex: "39FF14", unlitHex: "001400", accentHex: "00FF88", cost: 150),
        Theme(id: "solar",    name: "SOLAR",
              bgHex: "0A0800", dimHex: "1A1200", mistHex: "2E2000",
              litHex: "FFE566", unlitHex: "1A1200", accentHex: "FFAA00", cost: 200),
    ]

    static func theme(id: String) -> Theme { all.first { $0.id == id } ?? all[0] }

    // MARK: Current theme (observed globally)
    static var current: Theme = {
        let id = UserDefaults.standard.string(forKey: "mf.theme.v1") ?? "void"
        return theme(id: id)
    }()

    static func apply(_ theme: Theme) {
        current = theme
        UserDefaults.standard.set(theme.id, forKey: "mf.theme.v1")
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("mf.themeDidChange")
}

// MARK: - UIColor from hex

extension UIColor {
    static func hex(_ h: String) -> UIColor {
        var s = h.trimmingCharacters(in: .init(charactersIn: "#"))
        if s.count == 6 { s += "FF" }
        var val: UInt64 = 0
        Scanner(string: s).scanHexInt64(&val)
        return UIColor(
            red:   CGFloat((val >> 24) & 0xFF) / 255,
            green: CGFloat((val >> 16) & 0xFF) / 255,
            blue:  CGFloat((val >>  8) & 0xFF) / 255,
            alpha: CGFloat( val        & 0xFF) / 255
        )
    }
}

// MARK: - Themed Palette (dynamic wrappers used by UI)

enum TP {
    static var bg:     UIColor { .hex(ThemeStore.current.bgHex) }
    static var dim:    UIColor { .hex(ThemeStore.current.dimHex) }
    static var mist:   UIColor { .hex(ThemeStore.current.mistHex) }
    static var lit:    UIColor { .hex(ThemeStore.current.litHex) }
    static var unlit:  UIColor { .hex(ThemeStore.current.unlitHex) }
    static var accent: UIColor { .hex(ThemeStore.current.accentHex) }
}
