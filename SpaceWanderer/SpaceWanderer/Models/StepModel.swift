//
//  StepModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/12/24.
//

import Foundation

// JSON 인코딩을 위한 StepRequest 구조체
struct StepRequest: Codable {
    var userUniqueId: String
    var walkingDate: String
    var daySteps: Double
    var dayDestination: String = "천왕성"
}

// 서버 응답을 위한 StepResponse 구조체
struct StepResponse: Codable {
    var walkingDate: String
    var daySteps: Double
}
