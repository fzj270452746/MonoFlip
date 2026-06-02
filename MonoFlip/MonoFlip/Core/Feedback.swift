import UIKit
import AudioToolbox

enum Haptic {
    static func tap()     { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func fail()    { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func bump()    { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }
}

enum SFX {
    // Uses UIKit system sounds — no asset files needed
    static func flip()    { AudioServicesPlaySystemSound(1104) }   // Tock
    static func cleared() { AudioServicesPlaySystemSound(1025) }   // SMS received
    static func undo()    { AudioServicesPlaySystemSound(1155) }   // Camera shutter
}
