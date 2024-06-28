//
//  TabBarController.swift
//  NoteList
//
//  Created by Apple on 28/6/24.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    func setupTabBar() {
        // Set background color of the tab bar
        tabBar.barTintColor = .white
        tabBar.backgroundColor = .darkGray
        tabBar.tintColor = .white

        // Create NoteViewController and customize its tab bar item with a system icon
        let noteVC = NoteViewController()
        noteVC.tabBarItem = UITabBarItem(title: "Note", image: UIImage(systemName: "note.text"), tag: 0)

        // Create SettingsViewController and customize its tab bar item with a system icon
        let settingsVC = SettingViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

        // Assign view controllers to the tab bar controller
        viewControllers = [noteVC, settingsVC]
    }
}


