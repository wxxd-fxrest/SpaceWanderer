//
//  UNUserNotificationCenter.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/28/24.
//

import UserNotifications

extension UNUserNotificationCenter {
    
    // 푸시 알림을 예약하는 메서드
    func scheduleStepGoalNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "왹져의 여행"
        content.body = message
        content.sound = .default

        // 고유한 identifier 생성 (현재 시간 기반)
        let uniqueIdentifier = "stepGoalNotification_\(UUID().uuidString)"

        // 알림을 즉시 보냄
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: uniqueIdentifier, content: content, trigger: trigger)

        // 알림을 등록
        self.add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("푸시 알림이 성공적으로 전송되었습니다. [\(uniqueIdentifier)]")
            }
        }
    }
}
