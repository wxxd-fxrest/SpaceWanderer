//
//  CalendarViewModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 12/2/24.
//

import UIKit

class CalendarViewModel {
    // MARK: - 캘린더 컬렉션
    let calendar = Calendar.current
    var stepData: [Date: (Int, String)] = [:] // 날짜별 걸음 수와 행성 정보 데이터
    var planets: [Planet] = []

    // MARK: - 데이터 가져오기
    func fetchStepData(for userUniqueId: String, year: Int, month: Int, completion: @escaping (Result<[Date: (Int, String)], Error>) -> Void) {
        UserAPIManager.shared.fetchMonthStepData(for: userUniqueId, year: year, month: month) { result in
            switch result {
            case .success(let stepData):
                let convertedData = self.convertStepEntitiesToDictionary(stepData)
                completion(.success(convertedData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchPlanets(completion: @escaping (Result<[Planet], Error>) -> Void) {
        PlanetAPIManager.shared.fetchPlanets { result in
            switch result {
            case .success(let planets):
                completion(.success(planets))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 데이터 변환
    private func convertStepEntitiesToDictionary(_ stepEntities: [StepRequest]) -> [Date: (Int, String)] {
        var stepData: [Date: (Int, String)] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        for entity in stepEntities {
            if let utcDate = formatter.date(from: entity.walkingDate) {
                let localDate = Calendar.current.startOfDay(for: utcDate)
                
                let steps = Int(entity.daySteps)
                guard steps > 0 else { continue }
                
                if let existingData = stepData[localDate] {
                    let existingSteps = existingData.0
                    stepData[localDate] = (existingSteps + steps, entity.dayDestination)
                } else {
                    stepData[localDate] = (steps, entity.dayDestination)
                }
            }
        }
        return stepData
    }
}
