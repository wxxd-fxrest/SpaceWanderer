//
//  NotificationManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/18/24.
//

//import UIKit
//import UserNotifications
//import HealthKit
//
//class HealthKitManager {
//    static let shared = HealthKitManager()
//    private let healthStore = HKHealthStore()
//
//    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
//        guard HKHealthStore.isHealthDataAvailable() else {
//            completion(false, nil)
//            return
//        }
//
//        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//        let dataTypes: Set = [stepCountType]
//
//        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { success, error in
//            completion(success, error)
//        }
//    }
//}
//
//class StepCountManager {
//    static let shared = StepCountManager()
//    private let healthStore = HKHealthStore()
//
//    // 오늘의 걸음 수 가져오기
//    func getTodayStepCount(completion: @escaping (Int) -> Void) {
//        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
//            completion(0)
//            return
//        }
//
//        let startOfDay = Calendar.current.startOfDay(for: Date())
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
//        
//        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
//            var stepCount = 0
//            if let sum = result?.sumQuantity() {
//                stepCount = Int(sum.doubleValue(for: HKUnit.count()))
//            }
//            completion(stepCount)
//        }
//
//        healthStore.execute(query)
//    }
//}
//
//struct StepData: Codable {
//    var deviceToken: String
//    var steps: Int
//}
//
//class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
//    static let shared = NotificationManager()
//    private var timer: Timer?
//    private var lastStepCount = 0
//    
//    lazy var backendURL: String = {
//        // Space.plist에서 BackendURL 가져오기
//        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
//           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
//           let backendURL = spaceDict["NOTIFICCATION_URL"] as? String {
//            print("NOTIFICCATION_URL", backendURL)
//
//            return backendURL
//        } else {
//            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
//            return "http://localhost:1020" // 기본값 설정
//        }
//    }()
//    
//    // 5분마다 걸음 수 확인
//    func startMonitoring() {
//        // 백그라운드 큐에서 타이머 실행
//        DispatchQueue.global(qos: .background).async {
//            // 타이머를 백그라운드에서 실행하고, 주기적으로 걸음 수를 체크합니다.
//            self.timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
//                guard let self = self else { return }
//
//                StepCountManager.shared.getTodayStepCount { stepCount in
//                    print("현재 걸음 수: \(stepCount)")
//
//                    if stepCount > self.lastStepCount {
//                        self.lastStepCount = stepCount
//
//                        if stepCount >= 20 {
//                            self.handleStepGoalAchieved(stepCount: stepCount)
//                        }
//                    }
//                }
//            }
//
//            // 타이머는 메인 스레드에서 실행되어야 하므로 메인 스레드로 전달
//            DispatchQueue.main.async {
//                RunLoop.main.add(self.timer!, forMode: .common)
//            }
//        }
//    }
//
//
//     private func handleStepGoalAchieved(stepCount: Int) {
//         // 서버로 데이터 전송
//         if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") {
//             self.sendStepDataToServer(deviceToken: deviceToken, steps: stepCount)
//         } else {
//             print("Device Token이 등록되지 않았습니다.")
//         }
//
//         // 로컬 알림 발송
//         self.sendLocalNotification(for: stepCount)
//     }
//
//     func stopMonitoring() {
//         timer?.invalidate()
//         timer = nil
//     }
//
//     private func sendLocalNotification(for stepCount: Int) {
//         let content = UNMutableNotificationContent()
//         content.title = "축하합니다!"
//         content.body = "오늘 \(stepCount) 걸음을 달성했습니다. 계속 힘내세요!"
//         content.sound = .default
//
//         let request = UNNotificationRequest(
//             identifier: UUID().uuidString,
//             content: content,
//             trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//         )
//         UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//     }
//    
//    func registerForPushNotifications() {
//        // UNUserNotificationCenter 설정
//        let center = UNUserNotificationCenter.current()
//        center.delegate = self
//        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
//            if let error = error {
//                print("푸시 알림 권한 요청 실패: \(error.localizedDescription)")
//                return
//            }
//            if granted {
//                DispatchQueue.main.async {
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//            } else {
//                print("푸시 알림 권한이 거부되었습니다.")
//            }
//        }
//    }
//    
//    // 푸시 알림 권한 확인 (선택적으로 추가)
//     func checkNotificationAuthorizationStatus(completion: @escaping (Bool) -> Void) {
//         UNUserNotificationCenter.current().getNotificationSettings { settings in
//             completion(settings.authorizationStatus == .authorized)
//         }
//     }
//
//    // 푸시 알림 등록 성공 시 호출되는 메서드
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
//        UserDefaults.standard.set(deviceTokenString, forKey: "deviceToken")
//        print("Device Token 등록 완료: \(deviceTokenString)")
//    }
//
//    // 푸시 알림 등록 실패 시 호출되는 메서드
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register for push notifications: \(error.localizedDescription)")
//    }
//}
//
//extension NotificationManager {
//    func sendStepDataToServer(deviceToken: String, steps: Int) {
//        
//        print("deviceToken: ", deviceToken)
//        print("steps: ", steps)
//        guard let url = URL(string: "\(backendURL)") else {
//            print("잘못된 서버 URL")
//            return
//        }
//
//        let stepData = StepData(deviceToken: deviceToken, steps: steps)
//        do {
//            let jsonData = try JSONEncoder().encode(stepData)
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody = jsonData
//
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("서버 전송 오류: \(error.localizedDescription)")
//                    return
//                }
//
//                if let response = response as? HTTPURLResponse {
//                    print("서버 응답 상태 코드: \(response.statusCode)")
//                }
//            }
//
//            task.resume()
//        } catch {
//            print("데이터 인코딩 실패: \(error.localizedDescription)")
//        }
//    }
//}




//import UIKit
//import UserNotifications
//import HealthKit
//
//struct StepData: Codable {
//    var deviceToken: String
//    var steps: Int
//}
//
//class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
//    
//    lazy var backendURL: String = {
//        // Space.plist에서 BackendURL 가져오기
//        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
//           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
//           let backendURL = spaceDict["NOTIFICCATION_URL"] as? String {
//            print("NOTIFICCATION_URL", backendURL)
//
//            return backendURL
//        } else {
//            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
//            return "http://localhost:1020" // 기본값 설정
//        }
//    }()
//    
//}
//
//extension NotificationManager {
//    
//}


import UIKit
import HealthKit
import UserNotifications

struct StepData: Codable {
    var deviceToken: String
    var steps: Int
}

class StepNotificationManager {
    
    static let shared = StepNotificationManager()
    private let healthStore = HKHealthStore()
    private var lastStepCount = 0
    private var timer: Timer?
    
    // 서버의 푸시 알림 API URL
    private var backendURL: String {
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["NOTIFICCATION_URL"] as? String {
            return backendURL
        } else {
            return "http://localhost:1020" // 기본값 설정
        }
    }
    
    // HealthKit에서 걸음 수 가져오기
    func getTodayStepCount(completion: @escaping (Int) -> Void) {
        print("getTodayStepCount start")
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            var stepCount = 0
            if let sum = result?.sumQuantity() {
                stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                print("getTodayStepCount stepCount: ", stepCount)
            }
            completion(stepCount)
        }

        healthStore.execute(query)
    }

    // 10,000보 이상 달성 시 푸시 알림 API 요청
    @objc func checkAndSendPushNotification() {
        print("checkAndSendPushNotification")
        getTodayStepCount { [weak self] stepCount in
            guard let self = self else { return }
            
            print("현재 걸음 수: \(stepCount)")
            
            if stepCount > self.lastStepCount {
                self.lastStepCount = stepCount
                
                if stepCount >= 70 {
                    print("checkAndSendPushNotification stepCount: ", stepCount)
                    self.sendPushNotificationRequest(steps: stepCount)
                }
            }
        }
    }
    
    // 서버에 푸시 알림 요청
    private func sendPushNotificationRequest(steps: Int) {
        print("sendPushNotificationRequest steps: ", steps)
        guard let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") else {
            print("Device Token이 등록되지 않았습니다.")
            return
        }

        let url = URL(string: "\(backendURL)")!
        var request = URLRequest(url: url)
        print("sendPushNotificationRequest backendURL: ", backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let stepData = StepData(deviceToken: deviceToken, steps: steps)
        
        do {
            let jsonData = try JSONEncoder().encode(stepData)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("서버 요청 오류: \(error.localizedDescription)")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("서버 응답 상태 코드: \(response.statusCode)")
                }
                
                print("sendPushNotificationRequest data: ", data)
            }
            
            task.resume()
        } catch {
            print("JSON 인코딩 오류: \(error.localizedDescription)")
        }
    }

    // 백그라운드에서 일정 주기로 걸음 수 체크
    func startMonitoring() {
        print("startMonitoring")
        // 5초마다 걸음 수 확인 (디버깅을 위해 시간을 5초로 줄임)
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(checkAndSendPushNotification), userInfo: nil, repeats: true)
        print("Timer scheduled")
    }

    
    // 타이머 중지
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
}
