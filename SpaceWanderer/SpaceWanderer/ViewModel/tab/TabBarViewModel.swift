//
//  TabBarViewModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/23/24.
//

import UIKit
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
        guard let userIdentifier = userIdentifier else {
            print("userIdentifier가 nil입니다.")
            return
        }
        
        UserAPIManager.shared.getUser(by: userIdentifier) { result in
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
        self.origin = "출신: \(userEntity.inhabitedPlanet ?? "정보 없음")"
        self.birthday = "생일: \(userEntity.birthDay ?? "정보 없음")"
        self.profileImage = "\(userEntity.profileImage ?? "LaunchScreenIcon")"
        self.location = "\(userEntity.destinationPlanet ?? "")으로 가는 중"
        self.totalGoals = "\(userEntity.dayGoalCount)"
    }
}
