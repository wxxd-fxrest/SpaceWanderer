//
//  SelectProfileImageViewModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 12/2/24.
//

import Foundation

class SelectProfileImageViewModel {
    var userIdentifier: String?
    var nickname: String?
    var birthDay: String?

    func updateProfile(imageName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userIdentifier = userIdentifier,
              let nickname = nickname,
              let birthDay = birthDay else {
            completion(.failure(NSError(domain: "Missing user data", code: -1, userInfo: nil)))
            return
        }

        // APIManager를 사용하여 프로필 업데이트
        UserAPIManager.shared.updateProfile(userIdentifier: userIdentifier, nickname: nickname, birthDay: birthDay, inhabitedPlanet: "수성", profileImage: imageName) { result in
            completion(result)
        }
    }
}
