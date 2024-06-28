import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    func setupTabBar() {
        // Set background color of the tab bar
        tabBar.barTintColor = .darkGray
        tabBar.backgroundColor = .white
        tabBar.tintColor = .systemBlue

        // Create NoteViewController and customize its tab bar item with a system icon
        let noteVC = NoteViewController()
        noteVC.title = "Note"
        noteVC.tabBarItem = UITabBarItem(title: "Note", image: UIImage(systemName: "note.text"), tag: 0)

        // Create SettingsViewController and customize its tab bar item with a system icon
        let settingsVC = SettingViewController()
        settingsVC.title = "Settings"
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 1)

        // Assign view controllers to the tab bar controller
        viewControllers = [noteVC, settingsVC]
    }
}
