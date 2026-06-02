import UIKit

enum Palette {
    static let ink   = UIColor.black
    static let paper = UIColor.white
    static let void  = UIColor(white: 0.06, alpha: 1)
    static let dim   = UIColor(white: 0.12, alpha: 1)
    static let mist  = UIColor(white: 0.18, alpha: 1)
    static let ghost = UIColor(white: 0.35, alpha: 1)
    static let fog   = UIColor(white: 0.55, alpha: 1)

    // accent — subtle neon used sparingly
    static let pulse = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1)
    static let spark = UIColor(red: 0.6, green: 1.0, blue: 0.8, alpha: 1)
    static let warn  = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1)
}

enum Layout {
    static func scale(_ base: CGFloat) -> CGFloat {
        let ref: CGFloat = 390   // iPhone 14 logical width
        let w = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        // cap the scale so iPad compat mode doesn't become huge
        return base * min(w / ref, 1.4)
    }

    static var isCompact: Bool {
        UIScreen.main.bounds.width <= 428
    }
}
