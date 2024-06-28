import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Check login state
        LoginHelper.checkLoginStatus { isLoggedIn, _ in
            DispatchQueue.main.async {
                if isLoggedIn {
                    self.setupTabBarController()
                } else {
                    self.showLoginScreen()
                }
            }
        }
    }

    func setupTabBarController() {
        let tabBarController = TabBarController()

        // Replace with your NoteViewController setup
        let noteViewController = NoteViewController()
        let settingsViewController = SettingViewController()

        // Customize tab bar items
        noteViewController.tabBarItem = UITabBarItem(title: "Notes", image: UIImage(systemName: "note.text"), tag: 0)
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)

        // Add view controllers to the tab bar controller
        tabBarController.viewControllers = [noteViewController, settingsViewController]

        let navigationController = UINavigationController(rootViewController: tabBarController)

        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }

    func showLoginScreen() {
        let loginViewController = LoginViewController() // Replace with your login view controller
        self.window?.rootViewController = loginViewController
        self.window?.makeKeyAndVisible()
    }

    // Other UISceneDelegate methods...
}
