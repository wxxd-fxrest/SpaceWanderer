//
//  MainViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
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
        
//        mainView.showGoalMessage()
        
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
