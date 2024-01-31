//
//  Created by Aliaksandr Strakovich on 11.02.22.
//

import UIKit

enum TestHelper {
    static let isRunningUnitTests: Bool = NSClassFromString("XCTest") != nil
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard !TestHelper.isRunningUnitTests else { return }
        guard let ws = scene as? UIWindowScene else { return }

        let window = UIWindow(frame: ws.coordinateSpace.bounds)
        window.windowScene = ws

        let navigationController = UINavigationController()
        appCoordinator = {
            let coordinator = AppCoordinator(navigationController: navigationController)
            coordinator.start()
            return coordinator
        }()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
