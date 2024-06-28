import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let tabBarController = TabBarController() // Create an instance of TabBarController

        // Replace with your NoteViewController setup
        let noteViewController = NoteViewController()
        let settingsViewController = SettingViewController()

        // Customize tab bar items
        noteViewController.tabBarItem = UITabBarItem(title: "Notes", image: UIImage(systemName: "note.text"), tag: 0)
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)

        // Add view controllers to the tab bar controller
        tabBarController.viewControllers = [noteViewController, settingsViewController]

        let navigationController = UINavigationController(rootViewController: tabBarController)

        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    // Other UISceneDelegate methods...
}
