//
//  UserModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/12/24.
//

import Foundation

struct UserModel: Codable {
    let userUniqueId: String
    let userIdentifier: String
    let nickname: String?
    let birthDay: String?
    let inhabitedPlanet: String?
    let profileImage: String?
    let dayGoalCount: Int
    let destinationPlanet: String?
}
