//
//  TabBarViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/5/24.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    var userUniqueId: String?
    var userIdentifier: String?

    init(userUniqueId: String?, userIdentifier: String?) {
        self.userUniqueId = userUniqueId
        self.userIdentifier = userIdentifier
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
        setUpVCs()
    }
    
    func setUpTabBar() {
        tabBar.unselectedItemTintColor = SpecialColors.TabUnSelectColor.withAlphaComponent(0.54)
        tabBar.tintColor = SpecialColors.TabSelectColor
        tabBar.backgroundColor = SpecialColors.WhiteColor.withAlphaComponent(0.0)
    }

    func setUpVCs() {
        let mainVC = MainViewController()
        mainVC.userUniqueId = userUniqueId
        mainVC.userIdentifier = userIdentifier
        
        let calendarVC = CalendarViewController()
        calendarVC.userUniqueId = userUniqueId
        calendarVC.userIdentifier = userIdentifier
        
        let profileVC = ProfileViewController()
        profileVC.userUniqueId = userUniqueId
        profileVC.userIdentifier = userIdentifier

        let mainNavController = createNavController(for: mainVC, title: NSLocalizedString("Main", comment: ""), image: UIImage(named: "HouseIcon")!)
        let calendarNavController = createNavController(for: calendarVC, title: NSLocalizedString("Calendar", comment: ""), image: UIImage(named: "CalendarIcon")!)
        let profileNavController = createNavController(for: profileVC, title: NSLocalizedString("Profile", comment: ""), image: UIImage(named: "UserIcon")!)

        // 여백 추가
        mainNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0) // 위쪽 여백
        calendarNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0) // 위쪽 여백
        profileNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0) // 위쪽 여백

        viewControllers = [mainNavController, calendarNavController, profileNavController]
    }

    private func createNavController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UIView.transition(with: tabBarController.view, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
}
