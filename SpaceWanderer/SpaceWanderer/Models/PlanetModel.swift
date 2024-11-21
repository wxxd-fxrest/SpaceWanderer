//
//  PlanetModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/21/24.
//

import Foundation

struct Planet: Decodable {
    let id: String
    let name: String
    let description: String
    let imageUrl: String
    let requiredSteps: Int
}

// 서버에서 받는 요청을 위해 planetName을 감싸는 구조체 생성
//struct PlanetUpdateRequest: Codable {
//    let planetName: String
//}
