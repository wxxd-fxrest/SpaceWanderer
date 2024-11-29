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
    
    var viewModel: TabBarViewModel?
    
    // 로딩 인디케이터
    var loadingIndicator: UIActivityIndicatorView!

    init(userUniqueId: String?, userIdentifier: String?) {
        self.userUniqueId = userUniqueId
        self.userIdentifier = userIdentifier
        self.viewModel = TabBarViewModel()
        self.viewModel?.userIdentifier = userIdentifier
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
        setupLoadingIndicator()
        
        // NotificationCenter에 observer 등록
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .planetUpdatedTabBar, object: nil)
    }
    
    @objc func updateData() {
        // 데이터를 다시 가져오는 로직 또는 UI 업데이트 로직
        fetchUserData() // 예: 행성 목록을 다시 가져옴
        print("Tabbar 재 업데이트")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .planetUpdatedTabBar, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchUserData()
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = view.center
        loadingIndicator.color = .orange
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
    private func fetchUserData() {
        guard let viewModel = viewModel else { return }
        
        // 로딩 인디케이터 시작
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        
        viewModel.fetchUserData { [weak self] result in
            DispatchQueue.main.async {
                // 로딩 인디케이터 중지
                self?.loadingIndicator.stopAnimating()
            }
            
            switch result {
            case .success(let userEntity):
                // 사용자 정보를 업데이트
                viewModel.updateUserInfo(userEntity: userEntity)
                print("userEntityuserEntity: ", userEntity)
                self?.updateUI()
            case .failure(let error):
                DispatchQueue.main.async {
                    print("사용자 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let mainNavController = self.viewControllers?[0] as? UINavigationController,
               let mainVC = mainNavController.viewControllers.first as? MainViewController {
                mainVC.totalGoals = self.viewModel?.totalGoals
            }
            
            if let profileNavController = self.viewControllers?.last as? UINavigationController,
               let profileVC = profileNavController.viewControllers.first as? ProfileViewController {
                profileVC.nickname = self.viewModel?.nickname
                profileVC.id = self.viewModel?.id
                profileVC.origin = self.viewModel?.origin
                profileVC.birthday = self.viewModel?.birthday
                profileVC.profileImage = self.viewModel?.profileImage
                profileVC.location = self.viewModel?.location
                profileVC.totalGoals = self.viewModel?.totalGoals
                profileVC.setUpdateProfileUI()
            }
            
            if let calendarNavController = self.viewControllers?[1] as? UINavigationController,
               let calendarVC = calendarNavController.viewControllers.first as? CalendarViewController {
                calendarVC.totalGoals = self.viewModel?.totalGoals
            }
        }
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

        let mainNavController = createNavController(for: mainVC, title: NSLocalizedString("", comment: ""), image: UIImage(named: "HouseIcon")!)
        let calendarNavController = createNavController(for: calendarVC, title: NSLocalizedString("", comment: ""), image: UIImage(named: "CalendarIcon")!)
        let profileNavController = createNavController(for: profileVC, title: NSLocalizedString("", comment: ""), image: UIImage(named: "UserIcon")!)

        viewControllers = [mainNavController, calendarNavController, profileNavController]
    }

    private func createNavController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
//        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UIView.transition(with: tabBarController.view, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
}
