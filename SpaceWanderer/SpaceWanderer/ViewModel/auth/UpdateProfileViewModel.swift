//
//  UpdateProfileViewModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/30/24.
//

import Foundation

class UpdateProfileViewModel {
    var userUniqueId: String?
    var userIdentifier: String?

    func validateNickname(_ nickname: String) -> Bool {
        let nicknamePattern = "^[a-zA-Z가-힣0-9]{2,12}$"
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
        return nicknamePredicate.evaluate(with: nickname)
    }

    func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func checkNicknameUniqueness(_ nickname: String, completion: @escaping (Bool) -> Void) {
        UserAPIManager.shared.checkNicknameUniqueness(nickname) { isUnique in
            completion(isUnique)
        }
    }
}
