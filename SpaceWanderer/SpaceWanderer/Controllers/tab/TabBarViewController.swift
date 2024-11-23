//
//  TabBarViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/5/24.
//

//import UIKit
//
//class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
//    var userUniqueId: String?
//    var userIdentifier: String?
//
//    var id: String?
//    var nickname: String?
//    var origin: String?
//    var birthday: String?
//    var profileImage: String?
//    var location: String?
//    var totalGoals: String?
//    
//    // 로딩 인디케이터
//    var loadingIndicator: UIActivityIndicatorView!
//
//    init(userUniqueId: String?, userIdentifier: String?) {
//        self.userUniqueId = userUniqueId
//        self.userIdentifier = userIdentifier
//        super.init(nibName: nil, bundle: nil)
//        self.delegate = self
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setUpTabBar()
//        setUpVCs()
//        setupLoadingIndicator()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        // 유저 데이터 가져오기
//        fetchUserData()
//    }
//    
//    private func setupLoadingIndicator() {
//        loadingIndicator = UIActivityIndicatorView(style: .medium)
//        loadingIndicator.center = view.center
//        loadingIndicator.color = .orange
//        loadingIndicator.hidesWhenStopped = true
//        view.addSubview(loadingIndicator)
//    }
//    
//    private func fetchUserData() {
//        let userManager = UserManager()
//
//        guard let userIdentifier = userIdentifier else {
//            print("userIdentifier가 nil입니다.")
//            return
//        }
//                
//        // 로딩 인디케이터 시작
//        loadingIndicator.startAnimating()
//        
//        userManager.getUser(by: userIdentifier) { result in
//            DispatchQueue.main.async {
//                // 로딩 인디케이터 중지
//                self.loadingIndicator.stopAnimating()
//            }
//            
//            switch result {
//            case .success(let userEntity):
//                DispatchQueue.main.async {
//                    // 사용자 정보를 UI에 업데이트
//                    print("사용자 ID: \(userEntity.userIdentifier)")
//                    print("fetchUserData userEntity:", userEntity)
//                    // 목적지 업데이트
//                    self.nickname = userEntity.nickname ?? "정보 없음" // destinationPlanet 업데이트
//                    self.id = "#\(userEntity.userUniqueId ?? "정보 없음")"
//                    self.origin = "출신 · \(userEntity.inhabitedPlanet ?? "정보 없음")"
//                    self.birthday = "생일 · \(userEntity.birthDay ?? "정보 없음")"
//                    self.profileImage = "\(userEntity.profileImage ?? "LaunchScreenIcon")"
//                    self.location = "\(userEntity.destinationPlanet ?? "")으로 가는 중"
//                    self.totalGoals = "\(userEntity.dayGoalCount ?? 0)"
//                    
//                    print("loadingIndicator totalGoals: ", self.totalGoals)
//                    
//                    // MainViewController 업데이트
//                    if let mainNavController = self.viewControllers?[0] as? UINavigationController,
//                       let mainVC = mainNavController.viewControllers.first as? MainViewController {
//                        mainVC.totalGoals = self.totalGoals
//                    }
//                    
//                    // ProfileViewController 업데이트
//                    if let profileNavController = self.viewControllers?.last as? UINavigationController,
//                       let profileVC = profileNavController.viewControllers.first as? ProfileViewController {
//                        profileVC.nickname = self.nickname
//                        profileVC.id = self.id
//                        profileVC.origin = self.origin
//                        profileVC.birthday = self.birthday
//                        profileVC.profileImage = self.profileImage
//                        profileVC.location = self.location
//                        profileVC.totalGoals = self.totalGoals
//                    }
//                    
//                    // MainViewController 업데이트
//                    if let calendarNavController = self.viewControllers?[1] as? UINavigationController,
//                       let calendarVC = calendarNavController.viewControllers.first as? CalendarViewController {
//                        calendarVC.totalGoals = self.totalGoals
//                    }
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    // 오류 처리 (예: 경고 창 표시)
//                    print("사용자 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    func setUpTabBar() {
//        tabBar.unselectedItemTintColor = SpecialColors.TabUnSelectColor.withAlphaComponent(0.54)
//        tabBar.tintColor = SpecialColors.TabSelectColor
//        tabBar.backgroundColor = SpecialColors.WhiteColor.withAlphaComponent(0.0)
//    }
//
//    func setUpVCs() {
//        let mainVC = MainViewController()
//        mainVC.userUniqueId = userUniqueId
//        mainVC.userIdentifier = userIdentifier
//        
//        let calendarVC = CalendarViewController()
//        calendarVC.userUniqueId = userUniqueId
//        calendarVC.userIdentifier = userIdentifier
//        
//        let profileVC = ProfileViewController()
//        profileVC.userUniqueId = userUniqueId
//        profileVC.userIdentifier = userIdentifier
//
//        let mainNavController = createNavController(for: mainVC, title: NSLocalizedString("Main", comment: ""), image: UIImage(named: "HouseIcon")!)
//        let calendarNavController = createNavController(for: calendarVC, title: NSLocalizedString("Calendar", comment: ""), image: UIImage(named: "CalendarIcon")!)
//        let profileNavController = createNavController(for: profileVC, title: NSLocalizedString("Profile", comment: ""), image: UIImage(named: "UserIcon")!)
//
//        // 여백 추가
//        mainNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0) // 위쪽 여백
//        calendarNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0) // 위쪽 여백
//        profileNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0) // 위쪽 여백
//
//        viewControllers = [mainNavController, calendarNavController, profileNavController]
//    }
//
//    private func createNavController(for rootViewController: UIViewController,
//                                     title: String,
//                                     image: UIImage) -> UIViewController {
//        let navController = UINavigationController(rootViewController: rootViewController)
//        navController.tabBarItem.title = title
//        navController.tabBarItem.image = image
//        return navController
//    }
//
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        UIView.transition(with: tabBarController.view, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
//    }
//}



// TabBarViewModel.swift
import Foundation

class TabBarViewModel {
    var userUniqueId: String?
    var userIdentifier: String?
    
    // 사용자 정보
    var nickname: String?
    var id: String?
    var origin: String?
    var birthday: String?
    var profileImage: String?
    var location: String?
    var totalGoals: String?
    
    // 로딩 인디케이터 처리
    var loadingIndicator: UIActivityIndicatorView!
    
    // UserManager 인스턴스를 사용하여 사용자 데이터를 가져옵니다.
    func fetchUserData(completion: @escaping (Result<UserModel, Error>) -> Void) {
        let userManager = UserManager()
        
        guard let userIdentifier = userIdentifier else {
            print("userIdentifier가 nil입니다.")
            return
        }
        
        userManager.getUser(by: userIdentifier) { result in
            switch result {
            case .success(let userEntity):
                completion(.success(userEntity))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 사용자 정보를 업데이트
    func updateUserInfo(userEntity: UserModel) {
        self.nickname = userEntity.nickname ?? "정보 없음"
        self.id = "#\(userEntity.userUniqueId)"
        self.origin = "출신 · \(userEntity.inhabitedPlanet ?? "정보 없음")"
        self.birthday = "생일 · \(userEntity.birthDay ?? "정보 없음")"
        self.profileImage = "\(userEntity.profileImage ?? "LaunchScreenIcon")"
        self.location = "\(userEntity.destinationPlanet ?? "")으로 가는 중"
        self.totalGoals = "\(userEntity.dayGoalCount)"
    }
}

// TabBarViewController.swift
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

        let mainNavController = createNavController(for: mainVC, title: NSLocalizedString("Main", comment: ""), image: UIImage(named: "HouseIcon")!)
        let calendarNavController = createNavController(for: calendarVC, title: NSLocalizedString("Calendar", comment: ""), image: UIImage(named: "CalendarIcon")!)
        let profileNavController = createNavController(for: profileVC, title: NSLocalizedString("Profile", comment: ""), image: UIImage(named: "UserIcon")!)

        mainNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0)
        calendarNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0)
        profileNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -8, right: 0)

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
