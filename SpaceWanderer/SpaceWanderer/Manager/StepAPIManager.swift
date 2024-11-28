//
//  StepAPIManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/28/24.
//

import UIKit

class StepAPIManager {
    static let shared = StepAPIManager()

    lazy var backendURL: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["DAYSTEP_BASE_URL"] as? String {
            print("DAYSTEP_BASE_URL", backendURL)

            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()

    // 걸음 수 데이터를 서버에 전송 (새로 기록)
    func sendStepsToServer(userUniqueId: String, steps: Double, date: String, destination: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(backendURL)/day-walking") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let stepRequest = StepRequest(userUniqueId: userUniqueId, walkingDate: date, daySteps: steps, dayDestination: destination)

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(stepRequest)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // 서버 응답 처리
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "Invalid Response", code: -2, userInfo: nil)))
                    return
                }

                completion(.success(()))
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    // 마지막 기록된 날짜 가져오기
     func fetchLastRecordedDate(userUniqueId: String, completion: @escaping (Result<String, Error>) -> Void) {
         let url = URL(string: "\(backendURL)/last-recorded-date/\(userUniqueId)")!
         var request = URLRequest(url: url)
         request.httpMethod = "GET"

         let task = URLSession.shared.dataTask(with: request) { data, response, error in
             if let error = error {
                 completion(.failure(error))
                 return
             }

             guard let data = data else {
                 completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                 return
             }

             do {
                 let decoder = JSONDecoder()
                 let lastStepResponse = try decoder.decode(StepResponse.self, from: data)
                 let lastRecordedDate = lastStepResponse.walkingDate ?? Date().getTodayDate()  // nil일 경우 오늘 날짜로 설정
                 completion(.success(lastRecordedDate))
             } catch {
                 completion(.failure(error))
             }
         }
         task.resume()
     }
}
