//
//  MainViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//
//
//import UIKit
//import CoreMotion
//import UserNotifications
//
//class MainViewController: UIViewController {
//    let mainView = MainView()
//    let planetView = AddPlanetView()
//
//    var userUniqueId: String?
//    var userIdentifier: String?
//    var totalGoals: String?
//    var destination: String?
//    
//    let pedometer = CMPedometer()
//    
//    var totalStepsToday: Double = 0.0
//    var realTimeSteps: Double = 0.0
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = SpecialColors.PupleColor
//
//        view.addSubview(mainView)
//        mainView.frame = view.bounds
//        addStars(starCount: 100)
//        fetchTotalStepsForToday()
//        startRealTimeStepUpdates()
//        planetView.addMarsImage(to: self.view)
//        mainView.setDestinationUI()
//        mainView.destinationButtonTapped = { [weak self] in
//            self?.navigateToDestinationSelection()
//        }
//        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .planetUpdatedMain, object: nil)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        fetchUserData()
//    }
//    
//    @objc func updateData() {
//        fetchUserData()
//        print("재 업데이트")
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: .planetUpdatedMain, object: nil)
//    }
//    
//    @objc private func navigateToDestinationSelection() {
//        let destinationVC = DestinationSelectionViewController()
//        destinationVC.userIdentifier = userIdentifier
//        destinationVC.totalGoals = totalGoals
//        destinationVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(destinationVC, animated: true)
//    }
//    
//    @objc private func navigateToDetailPage() {
//        let detailVC = StepDetailViewController()
//        detailVC.date = Date()
//        
//        let totalStepsToday = self.totalStepsToday + self.realTimeSteps
//        detailVC.steps = Int(totalStepsToday)
//        detailVC.dayDestination = mainView.destinationLabel.text
//        detailVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
//    
//    private func fetchUserData() {
//        guard let userIdentifier = userIdentifier else {
//            print("userIdentifier가 nil입니다.")
//            return
//        }
//                
//        DispatchQueue.main.async {
//            self.mainView.startLoading()
//        }
//        
//        UserAPIManager.shared.getUser(by: userIdentifier) { result in
//            DispatchQueue.main.async {
//                self.mainView.stopLoading()
//            }
//            
//            switch result {
//            case .success(let userEntity):
//                DispatchQueue.main.async {
//                    self.mainView.destinationLabel.text = userEntity.destinationPlanet ?? "정보 없음"
//                    self.fetchLastRecordedDate()
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    print("사용자 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    func fetchLastRecordedDate() {
//        guard let userUniqueId = userUniqueId else { return }
//        
//        StepAPIManager.shared.fetchLastRecordedDate(userUniqueId: userUniqueId) { result in
//            switch result {
//            case .success(let lastRecordedDate):
//                if lastRecordedDate.isEmpty {
//                    self.fetchAndSendSteps(forDate: Date().getTodayDate())
//                } else {
//                    self.handleMissingDates(lastRecordedDate: lastRecordedDate)
//                }
//            case .failure(let error):
//                self.fetchAndSendSteps(forDate: Date().getTodayDate())
//            }
//        }
//    }
//
//    func handleMissingDates(lastRecordedDate: String) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        
//        let todayDate = dateFormatter.string(from: Date())
//        var currentDate = lastRecordedDate
//        
//        while currentDate != todayDate {
//            fetchAndSendSteps(forDate: currentDate)
//            
//            if let date = dateFormatter.date(from: currentDate) {
//                let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
//                currentDate = dateFormatter.string(from: nextDate)
//            }
//        }
//        
//        if currentDate == todayDate {
//            fetchAndSendSteps(forDate: currentDate)
//        }
//    }
//    
//    func fetchAndSendSteps(forDate date: String) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        
//        guard let targetDate = dateFormatter.date(from: date) else {
//            return
//        }
//
//        let startOfDay = Calendar.current.startOfDay(for: targetDate)
//        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
//        
//        pedometer.queryPedometerData(from: startOfDay, to: endOfDay) { data, error in
//            guard error == nil, let data = data else {
//                return
//            }
//
//            let deviceSteps = data.numberOfSteps.doubleValue
//            self.sendStepsToServer(steps: deviceSteps, date: date)
//        }
//    }
//
//    func sendStepsToServer(steps: Double, date: String) {
//        guard let userUniqueId = userUniqueId else { return }
//        
//        // destinationLabel.text를 메인 스레드에서 가져오기
//        DispatchQueue.main.sync {
//            destination = mainView.destinationLabel.text
//        }
//        
//        // destination 값이 nil인지 확인
//        guard let destination = destination else { return }
//        
//        StepAPIManager.shared.sendStepsToServer(userUniqueId: userUniqueId, steps: steps, date: date, destination: destination) { result in
//            switch result {
//            case .success:
//                print("걸음 수 데이터가 서버에 성공적으로 전송되었습니다.")
//            case .failure(let error):
//                print("서버로 데이터 전송 중 오류 발생: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func fetchTotalStepsForToday() {
//        guard CMPedometer.isStepCountingAvailable() else {
//            print("걸음 수 계산을 사용할 수 없습니다.")
//            return
//        }
//
//        let now = Date()
//        let startOfDay = Calendar.current.startOfDay(for: now)
// 
//        pedometer.queryPedometerData(from: startOfDay, to: now) { data, error in
//            guard error == nil, let data = data else {
//                print("걸음 수를 가져오는 중 오류가 발생했습니다: \(String(describing: error))")
//                return
//            }
//
//            self.totalStepsToday = data.numberOfSteps.doubleValue
//            DispatchQueue.main.async {
//                print("오늘 걸음 수(자정부터): \(self.totalStepsToday)")
//                self.checkForStepGoal()
//                self.updateCircularProgressBar()
//                self.mainView.updateStepLabel(with: Int(self.totalStepsToday + self.realTimeSteps))
//            }
//        }
//    }
//    
//    func startRealTimeStepUpdates() {
//        guard CMPedometer.isStepCountingAvailable() else {
//            print("걸음 수 계산을 사용할 수 없습니다.")
//            return
//        }
//        
//        pedometer.startUpdates(from: Date()) { data, error in
//            guard error == nil, let data = data else {
//                print("실시간 단계 업데이트 오류: \(String(describing: error))")
//                return
//            }
//            
//            self.realTimeSteps = data.numberOfSteps.doubleValue
//            DispatchQueue.main.async {
//                print("실시간 걸음 수: \(self.realTimeSteps)")
//                self.checkForStepGoal()
//                self.updateCircularProgressBar()
//                self.mainView.updateStepLabel(with: Int(self.totalStepsToday + self.realTimeSteps))
//            }
//        }
//    }
//    
//    func checkForStepGoal() {
//        let totalSteps = self.totalStepsToday + self.realTimeSteps
//        
//        let lastNotificationDate = UserDefaults.standard.object(forKey: "lastNotificationDate") as? Date ?? Date.distantPast
//        let calendar = Calendar.current
//        let currentDate = Date()
//
//        if UserDefaults.standard.object(forKey: "notificationSentFor8k") == nil {
//            UserDefaults.standard.set(false, forKey: "notificationSentFor8k")
//        }
//        if UserDefaults.standard.object(forKey: "notificationSentFor10k") == nil {
//            UserDefaults.standard.set(false, forKey: "notificationSentFor10k")
//        }
//
//        if !calendar.isDate(lastNotificationDate, inSameDayAs: currentDate) {
//            UserDefaults.standard.set(false, forKey: "notificationSentFor8k")
//            UserDefaults.standard.set(false, forKey: "notificationSentFor10k")
//            UserDefaults.standard.set(currentDate, forKey: "lastNotificationDate")
//        }
//
//        if totalSteps >= 70, !UserDefaults.standard.bool(forKey: "notificationSentFor8k") {
//            UNUserNotificationCenter.current().scheduleStepGoalNotification(message: "대단해요! 이제 조금만 더 가면 목표 달성입니다!")
//            UserDefaults.standard.set(true, forKey: "notificationSentFor8k")
//        }
//        
//        if totalSteps >= 80, !UserDefaults.standard.bool(forKey: "notificationSentFor10k") {
//            UNUserNotificationCenter.current().scheduleStepGoalNotification(message: "축하합니다! 오늘 10,000걸음 목표를 달성하셨습니다!")
//            UserDefaults.standard.set(true, forKey: "notificationSentFor10k")
//        }
//    }
//
//    func updateCircularProgressBar() {
//        mainView.updateCircularProgressBar(totalStepsToday: totalStepsToday, realTimeSteps: realTimeSteps)
//        updateStepLabel()
//    }
//    
//    func updateStepLabel() {
//        let totalSteps = self.totalStepsToday + self.realTimeSteps
//        mainView.updateStepLabel(with: Int(totalSteps))
//        
//        if totalSteps >= 10000 {
//            mainView.showGoalMessage()
//        }
//    }
//}
//
//
//
//




import UIKit

class MainViewController: UIViewController, MainViewModelDelegate {
    let mainView = MainView()
    let planetView = AddPlanetView()
    var mainViewModel: MainViewModel?

    var userUniqueId: String?
    var userIdentifier: String?
    var totalGoals: String?
    var destination: String?
    
    var totalStepsToday: Double = 0.0
    var realTimeSteps: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.PupleColor

        // MainViewModel 초기화
        mainViewModel = MainViewModel(delegate: self, userIdentifier: userIdentifier, userUniqueId: userUniqueId, mainView: mainView)
        
        view.addSubview(mainView)
        mainView.frame = view.bounds
        addStars(starCount: 100)
        
        mainView.showGoalMessage()
        
        // MainViewModel 메서드 호출
        mainViewModel?.fetchTotalStepsForToday()
        mainViewModel?.startRealTimeStepUpdates()
        
        planetView.addMarsImage(to: self.view)
        mainView.setDestinationUI()
        
        mainView.destinationButtonTapped = { [weak self] in
            self?.navigateToDestinationSelection()
        }
        mainView.goalButtonTapped = { [weak self] in
            self?.navigateToDetailPage()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .planetUpdatedMain, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mainViewModel?.fetchUserData()
    }

    @objc func updateData() {
        mainViewModel?.fetchUserData()
        print("재 업데이트")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .planetUpdatedMain, object: nil)
    }
    
    // Delegate 메서드 구현
     func didUpdateTotalSteps(todaySteps: Double, realTimeSteps: Double) {
         self.totalStepsToday = todaySteps
         self.realTimeSteps = realTimeSteps
         
         // UI 업데이트
         DispatchQueue.main.async {
             self.updateStepLabel()
             self.updateCircularProgressBar()
         }
     }

    @objc private func navigateToDestinationSelection() {
        let destinationVC = DestinationSelectionViewController()
        destinationVC.userIdentifier = userIdentifier
        destinationVC.totalGoals = totalGoals
        destinationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    
//    @objc private func navigateToDetailPage() {
//        let totalStepsToday = self.totalStepsToday + self.realTimeSteps
//        let viewModel = StepDetailViewModel(date: Date(), steps: Int(totalStepsToday), dayDestination: mainView.destinationLabel.text)
//
//        let detailVC = StepDetailViewController()
//        detailVC.viewModel = viewModel // ViewModel을 설정
//        detailVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
    
    @objc private func navigateToDetailPage() {
        let totalStepsToday = self.totalStepsToday + self.realTimeSteps
        let viewModel = StepDetailViewModel(
            date: Date(),
            steps: Int(totalStepsToday),
            dayDestination: mainView.destinationLabel.text ?? ""
        )

        let detailVC = StepDetailViewController()
        detailVC.viewModel = viewModel // ViewModel 설정

        // 바텀 시트 설정
        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { _ in 300 }) // 300pt 고정 높이 설정
            ]
            sheet.prefersGrabberVisible = true // 핸들 표시
            sheet.prefersEdgeAttachedInCompactHeight = true // 컴팩트 모드에서 가장자리 고정
        }

        detailVC.modalPresentationStyle = .pageSheet // 모달 스타일 설정
        present(detailVC, animated: true) // 모달로 ViewController 표시
    }



    
    // 목표 걸음 수 체크하는 메서드
    func checkForStepGoal() {
        let totalSteps = self.totalStepsToday + self.realTimeSteps
        
        let lastNotificationDate = UserDefaults.standard.object(forKey: "lastNotificationDate") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let currentDate = Date()
        
        if UserDefaults.standard.object(forKey: "notificationSentFor8k") == nil {
            UserDefaults.standard.set(false, forKey: "notificationSentFor8k")
        }
        if UserDefaults.standard.object(forKey: "notificationSentFor10k") == nil {
            UserDefaults.standard.set(false, forKey: "notificationSentFor10k")
        }
        
        if !calendar.isDate(lastNotificationDate, inSameDayAs: currentDate) {
            UserDefaults.standard.set(false, forKey: "notificationSentFor8k")
            UserDefaults.standard.set(false, forKey: "notificationSentFor10k")
            UserDefaults.standard.set(currentDate, forKey: "lastNotificationDate")
        }
        
        if totalSteps >= 70, !UserDefaults.standard.bool(forKey: "notificationSentFor8k") {
            UNUserNotificationCenter.current().scheduleStepGoalNotification(message: "대단해요! 이제 조금만 더 가면 목표 달성입니다!")
            UserDefaults.standard.set(true, forKey: "notificationSentFor8k")
        }
        
        if totalSteps >= 80, !UserDefaults.standard.bool(forKey: "notificationSentFor10k") {
            UNUserNotificationCenter.current().scheduleStepGoalNotification(message: "축하합니다! 오늘 10,000걸음 목표를 달성하셨습니다!")
            UserDefaults.standard.set(true, forKey: "notificationSentFor10k")
        }
        
        print("알림 업데이트")
    }
    
    func updateCircularProgressBar() {
        mainView.updateCircularProgressBar(totalStepsToday: totalStepsToday, realTimeSteps: realTimeSteps)
        updateStepLabel()
    }
    
    
    func updateStepLabel() {
        let totalSteps = self.totalStepsToday + self.realTimeSteps
        mainView.updateStepLabel(with: Int(totalSteps))
        
        if totalSteps >= 10 {
            mainView.showGoalMessage()
        }
    }
}
