//
//  MainViewModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 12/2/24.
//

// MARK: 기본
//import UIKit
//import CoreMotion
//import UserNotifications
//
//protocol MainViewModelDelegate: AnyObject {
//    func checkForStepGoal()
//    func updateCircularProgressBar()
//    func didUpdateTotalSteps(todaySteps: Double, realTimeSteps: Double)
//}
//
//class MainViewModel {
//    weak var delegate: MainViewModelDelegate?
//
//    private let pedometer = CMPedometer()
//    private var userIdentifier: String?
//    private var userUniqueId: String?
//    private var destination: String?
//    private var mainView: MainView  // MainView를 전달받는 방식
//    
//    var totalStepsToday: Double = 0.0 {
//        didSet {
//            // 값이 업데이트되면 delegate 호출
//            delegate?.didUpdateTotalSteps(todaySteps: totalStepsToday, realTimeSteps: realTimeSteps)
//        }
//    }
//    
//    var realTimeSteps: Double = 0.0 {
//        didSet {
//            // 값이 업데이트되면 delegate 호출
//            delegate?.didUpdateTotalSteps(todaySteps: totalStepsToday, realTimeSteps: realTimeSteps)
//        }
//    }
//    
//    // 초기화
//    init(delegate: MainViewModelDelegate, userIdentifier: String?, userUniqueId: String?, mainView: MainView) {
//        self.delegate = delegate
//        self.userIdentifier = userIdentifier
//        self.userUniqueId = userUniqueId
//        self.mainView = mainView
//    }
//    
//    // 사용자 데이터를 가져오는 메서드
//    func fetchUserData() {
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
//    // 마지막으로 기록된 날짜를 가져오는 메서드
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
//    // 누락된 날짜들을 처리하는 메서드
//    func handleMissingDates(lastRecordedDate: String) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        
//        let todayDate = dateFormatter.string(from: Date())
//        var currentDate = lastRecordedDate
//        
//        while currentDate != todayDate {
//            fetchAndSendSteps(forDate: currentDate)
//            print("fetchAndSendSteps: ", fetchAndSendSteps)
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
//    // 지정된 날짜에 대한 걸음 수를 가져오는 메서드
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
//    // 서버에 걸음 수 전송하는 메서드
//    func sendStepsToServer(steps: Double, date: String) {
//        guard let userUniqueId = userUniqueId else { return }
//        
//        DispatchQueue.main.sync {
//            self.destination = mainView.destinationLabel.text
//        }
//        
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
//    // 오늘 걸음 수 가져오는 메서드
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
//                self.delegate?.checkForStepGoal()
//                self.delegate?.updateCircularProgressBar()
//                self.mainView.updateStepLabel(with: Int(self.totalStepsToday + self.realTimeSteps))
//            }
//        }
//    }
//    
//    // 실시간 단계 업데이트 시작하는 메서드
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
//                self.delegate?.checkForStepGoal()
//                self.delegate?.updateCircularProgressBar()
//                self.mainView.updateStepLabel(with: Int(self.totalStepsToday + self.realTimeSteps))
//            }
//        }
//    }
//}



// MARK: HEALTHKIT
import UIKit
import HealthKit
import UserNotifications

protocol MainViewModelDelegate: AnyObject {
    func checkForStepGoal()
    func updateCircularProgressBar()
    func didUpdateTotalSteps(todaySteps: Double, realTimeSteps: Double)
}

class MainViewModel {
    weak var delegate: MainViewModelDelegate?

    private let healthStore = HKHealthStore()
    private var userIdentifier: String?
    private var userUniqueId: String?
    private var destination: String?
    private var mainView: MainView
    
    var totalStepsToday: Double = 0.0 {
        didSet {
            delegate?.didUpdateTotalSteps(todaySteps: totalStepsToday, realTimeSteps: realTimeSteps)
        }
    }
    
    var realTimeSteps: Double = 0.0 {
        didSet {
            delegate?.didUpdateTotalSteps(todaySteps: totalStepsToday, realTimeSteps: realTimeSteps)
        }
    }
    
    init(delegate: MainViewModelDelegate, userIdentifier: String?, userUniqueId: String?, mainView: MainView) {
        self.delegate = delegate
        self.userIdentifier = userIdentifier
        self.userUniqueId = userUniqueId
        self.mainView = mainView
    }
    
    // 사용자 데이터를 가져오는 메서드
    func fetchUserData() {
        guard let userIdentifier = userIdentifier else {
            print("userIdentifier가 nil입니다.")
            return
        }
        
        DispatchQueue.main.async {
            self.mainView.startLoading()
        }
        
        UserAPIManager.shared.getUser(by: userIdentifier) { result in
            DispatchQueue.main.async {
                self.mainView.stopLoading()
            }
            
            switch result {
            case .success(let userEntity):
                DispatchQueue.main.async {
                    self.mainView.destinationLabel.text = userEntity.destinationPlanet ?? "정보 없음"
                    self.fetchLastRecordedDate()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("사용자 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // HealthKit 권한 요청
    func requestHealthKitPermissions() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let readTypes: Set<HKObjectType> = [stepCountType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if !success {
                print("HealthKit 권한 요청 실패: \(String(describing: error))")
            }
        }
    }
    
    // 마지막으로 기록된 날짜를 가져오는 메서드
    func fetchLastRecordedDate() {
        guard let userUniqueId = userUniqueId else { return }
        
        StepAPIManager.shared.fetchLastRecordedDate(userUniqueId: userUniqueId) { result in
            switch result {
            case .success(let lastRecordedDate):
                if lastRecordedDate.isEmpty {
                    self.fetchAndSendSteps(forDate: Date().getTodayDate())
                } else {
                    self.handleMissingDates(lastRecordedDate: lastRecordedDate)
                }
            case .failure(let error):
                self.fetchAndSendSteps(forDate: Date().getTodayDate())
            }
        }
    }
    
    // 누락된 날짜들을 처리하는 메서드
    func handleMissingDates(lastRecordedDate: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let todayDate = dateFormatter.string(from: Date())
        var currentDate = lastRecordedDate
        
        while currentDate != todayDate {
            fetchAndSendSteps(forDate: currentDate)
            if let date = dateFormatter.date(from: currentDate) {
                let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
                currentDate = dateFormatter.string(from: nextDate)
            }
        }
        
        if currentDate == todayDate {
            fetchAndSendSteps(forDate: currentDate)
        }
    }
    
    // 지정된 날짜에 대한 걸음 수를 HealthKit으로 가져오는 메서드
    func fetchAndSendSteps(forDate date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let targetDate = dateFormatter.date(from: date) else {
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: targetDate)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        
        // HealthKit에서 걸음 수 가져오기
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard error == nil, let result = result else {
                return
            }
            
            let deviceSteps = result.sumQuantity()?.doubleValue(for: .count()) ?? 0
            self.sendStepsToServer(steps: deviceSteps, date: date)
        }
        
        healthStore.execute(query)
    }
    
    // 서버에 걸음 수 전송하는 메서드
    func sendStepsToServer(steps: Double, date: String) {
        guard let userUniqueId = userUniqueId else { return }
        
        DispatchQueue.main.sync {
            self.destination = mainView.destinationLabel.text
        }
        
        guard let destination = destination else { return }
        
        StepAPIManager.shared.sendStepsToServer(userUniqueId: userUniqueId, steps: steps, date: date, destination: destination) { result in
            switch result {
            case .success:
                print("걸음 수 데이터가 서버에 성공적으로 전송되었습니다.")
            case .failure(let error):
                print("서버로 데이터 전송 중 오류 발생: \(error.localizedDescription)")
            }
        }
    }
    
    // 오늘 걸음 수 가져오는 메서드
    func fetchTotalStepsForToday() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit을 사용할 수 없습니다.")
            return
        }
        
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart)!
        
        let predicate = HKQuery.predicateForSamples(withStart: todayStart, end: todayEnd)
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard error == nil, let result = result else {
                print("오늘의 걸음 수를 가져오는 중 오류 발생")
                return
            }
            
            self.totalStepsToday = result.sumQuantity()?.doubleValue(for: .count()) ?? 0
            DispatchQueue.main.async {
                print("오늘 걸음 수(자정부터): \(self.totalStepsToday)")
                self.delegate?.checkForStepGoal()
                self.delegate?.updateCircularProgressBar()
                self.mainView.updateStepLabel(with: Int(self.totalStepsToday + self.realTimeSteps))
            }
        }
        
        healthStore.execute(query)
    }
    
    // 실시간 단계 업데이트 시작하는 메서드
    func startRealTimeStepUpdates() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit을 사용할 수 없습니다.")
            return
        }
        
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let query = HKObserverQuery(sampleType: stepCountType, predicate: nil) { _, _, error in
            if let error = error {
                print("실시간 단계 업데이트 오류: \(error.localizedDescription)")
            } else {
                self.fetchTotalStepsForToday()
            }
        }
        
        healthStore.execute(query)
    }
}
