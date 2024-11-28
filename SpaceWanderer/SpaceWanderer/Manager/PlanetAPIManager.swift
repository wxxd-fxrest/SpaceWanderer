//
//  PlanetAPIManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class PlanetAPIManager {
    static let shared = PlanetAPIManager()
    
    private init() {}
    
    lazy var backendURL: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["PLANET_BASE_URL"] as? String {
            print("PLANET_BASE_URL", backendURL)
            
            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()
    
    // API 호출을 통해 모든 행성 데이터를 가져오는 함수
    func fetchPlanets(completion: @escaping (Result<[Planet], Error>) -> Void) {
        guard let url = URL(string: "\(backendURL)/get-all-planet") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                // JSON 디코딩
                let decoder = JSONDecoder()
                let planets = try decoder.decode([Planet].self, from: data)
                completion(.success(planets))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
