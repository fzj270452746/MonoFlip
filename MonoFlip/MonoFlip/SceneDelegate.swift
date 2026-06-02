import UIKit
import AppTrackingTransparency


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let win = UIWindow(windowScene: windowScene)
        win.rootViewController = EntryScreen()
        win.backgroundColor = Palette.void
        window = win
        win.makeKeyAndVisible()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
    }
}

import Network

final class Kouts {

    static let shared = Kouts()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.MC.MoodCollapse", qos: .background)
    private var callback: ((Bool) -> Void)?
    private var started = false

    private init() {}

    func start(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        guard !started else { return }
        started = true

        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                self?.callback?(isConnected)
            }
        }

        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
        started = false
    }
}


