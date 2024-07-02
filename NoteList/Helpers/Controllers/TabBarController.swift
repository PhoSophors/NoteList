import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    func setupTabBar() {
        // Set background color of the tab bar
        tabBar.barTintColor = .darkGray
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .white

        // Create NoteViewController (embedded in a navigation controller)
        let noteVC = FolderViewController()
        noteVC.title = "Note"
        noteVC.tabBarItem = UITabBarItem(title: "Note", image: UIImage(systemName: "note.text"), tag: 0)
        let noteNavVC = UINavigationController(rootViewController: noteVC)

        // Create SettingsViewController (embedded in a navigation controller)
        let settingsVC = SettingViewController()
        settingsVC.title = "Settings"
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)
        let settingsNavVC = UINavigationController(rootViewController: settingsVC)

        // Assign view controllers to the tab bar controller
        viewControllers = [noteNavVC, settingsNavVC]
    }
}
