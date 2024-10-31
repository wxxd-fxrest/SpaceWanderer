//
//  AppleLoginResponse.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/31/24.
//

import Foundation

struct AppleLoginResponse {
    let userIdentifier: String?
    let refreshToken: String?
    let userUniqueId: String? // userUniqueId 추가
}
