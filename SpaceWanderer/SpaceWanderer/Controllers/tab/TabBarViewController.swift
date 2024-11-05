//
//  TabBarViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/5/24.
//

import UIKit

class TabBarViewController: UITabBarController {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    class CustomHeightTabBar: UITabBar {
      override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)

        guard let window = UIApplication.shared.connectedScenes
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter( { $0.isKeyWindow } ).first
        else { return sizeThatFits }

        let tabBarHeight: CGFloat = 36
        sizeThatFits.height = tabBarHeight + window.safeAreaInsets.bottom

        return sizeThatFits
      }
    }

    init(userUniqueId: String?, userIdentifier: String?, accessToken: String?) {
        self.userUniqueId = userUniqueId
        self.userIdentifier = userIdentifier
        self.accessToken = accessToken
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, CustomHeightTabBar.self)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
        setUpVCs()
        print("TabBarViewController Props: ", userUniqueId ?? "nil", accessToken ?? "nil", userIdentifier ?? "nil")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 탭바 위치 및 크기 조정
        let padding: CGFloat = 20 // 양쪽 여백
        var tabBarFrame = tabBar.frame
        tabBarFrame.origin.x = padding
        tabBarFrame.origin.y = view.frame.height - tabBarFrame.height - 24
        tabBarFrame.size.width = view.frame.width - (2 * padding)
        tabBar.frame = tabBarFrame
    }

    func setUpTabBar() {
        tabBar.unselectedItemTintColor = SpecialColors.TabUnSelectColor.withAlphaComponent(0.54)
        tabBar.tintColor = SpecialColors.TabSelectColor
        tabBar.backgroundColor = SpecialColors.WhiteColor.withAlphaComponent(0.18)

        tabBar.layer.cornerRadius = tabBar.frame.height * 0.60
        tabBar.clipsToBounds = true
    }

    func setUpVCs() {
        let mainVC = MainViewController()
        mainVC.userUniqueId = userUniqueId
        mainVC.accessToken = accessToken
        mainVC.userIdentifier = userIdentifier
        
        let calendarVC = CalendarViewController()
        calendarVC.userUniqueId = userUniqueId
        calendarVC.accessToken = accessToken
        calendarVC.userIdentifier = userIdentifier
        
        let profileVC = ProfileViewController()
        profileVC.userUniqueId = userUniqueId
        profileVC.accessToken = accessToken
        profileVC.userIdentifier = userIdentifier

        viewControllers = [
            createNavController(for: mainVC, title: NSLocalizedString("Main", comment: ""), image: UIImage(named: "home")!),
            createNavController(for: calendarVC, title: NSLocalizedString("Calender", comment: ""), image: UIImage(named: "calendar")!),
            createNavController(for: profileVC, title: NSLocalizedString("Profile", comment: ""), image: UIImage(named: "profile")!)
        ]
    }

    private func createNavController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.setNavigationBarHidden(true, animated: false)

        return navController
    }
}
