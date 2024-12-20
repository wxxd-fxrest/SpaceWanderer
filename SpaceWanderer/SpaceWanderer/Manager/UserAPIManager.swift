//
//  UserManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/12/24.
//

import Foundation

class UserAPIManager {
    static let shared = UserAPIManager()
    
    private init() {}

    lazy var backendURL: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["PROFILE_BASE_URL"] as? String {
            print("PROFILE_BASE_URL", backendURL)

            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()
    
    // MARK: - get user data
    func getUser(by userIdentifier: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        let url = URL(string: "\(backendURL)/\(userIdentifier)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Server error", code: 0, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let userEntity = try JSONDecoder().decode(UserModel.self, from: data)
                completion(.success(userEntity))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // 행성 업데이트 API 호출
    func updateUserPlanet(userIdentifier: String, planetName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(backendURL)/update-planet/\(userIdentifier)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // planetName을 JSON으로 전송
        let requestBody: [String: String] = ["destinationPlanet": planetName]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        // 서버 요청
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(.success(())) // 성공 시 빈 결과 반환
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update planet"])))
                }
            }
        }.resume()
    }
    
    // 월마다 Step 데이터를 가져오는 메서드
    func fetchMonthStepData(for userUniqueId: String, year: Int, month: Int, completion: @escaping (Result<[StepRequest], Error>) -> Void) {
        print("fetchStepData userUniqueId: ", userUniqueId, year, month)
        
        // 서버 URL 설정
        let url = URL(string: "\(backendURL)/calendar/steps/\(userUniqueId)?year=\(year)&month=\(month)")!
        var request = URLRequest(url: url)
        print("url", url)
        request.httpMethod = "GET"
        
        // 네트워크 요청 보내기
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching step data: \(error.localizedDescription)")
                completion(.failure(error))  // 오류가 발생한 경우
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))  // 데이터가 없을 경우 오류 처리
                return
            }
            
            // 서버에서 받은 데이터를 파싱하여 반환
            do {
                let stepData = try JSONDecoder().decode([StepRequest].self, from: data)
                completion(.success(stepData))  // 성공적으로 데이터가 파싱되었을 때
            } catch {
                print("Error decoding step data: \(error.localizedDescription)")
                completion(.failure(error))  // 파싱 오류 발생 시
            }
        }
        
        task.resume()
    }
    
    // 닉네임 유니크 체크 메서드
    func checkNicknameUniqueness(_ nickname: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(backendURL)/check-nickname/\(nickname)") else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            if let _ = error {
                completion(false)
                return
            }
            
            guard let data = data, let isUnique = try? JSONDecoder().decode(Bool.self, from: data) else {
                completion(false)
                return
            }
            
            completion(isUnique)
        }
        task.resume()
    }
    
    // 프로필 수정(회원가입 이후)
    func updateProfile(userIdentifier: String, requestData: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !requestData.isEmpty,
              let url = URL(string: "\(backendURL)/profile-update/\(userIdentifier)") else {
            completion(.failure(NSError(domain: "Invalid URL or empty request data", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // 성공적으로 업데이트된 경우
                completion(.success(()))
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    // 프로필 작성(회원가입 진행 시)
    func updateProfile(userIdentifier: String, nickname: String, birthDay: String, inhabitedPlanet: String, profileImage: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // URL 요청 준비
        guard let url = URL(string: "\(backendURL)/profile-write/\(userIdentifier)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData: [String: Any] = [
            "nickname": nickname,
            "birthDay": birthDay,
            "inhabitedPlanet": inhabitedPlanet,
            "profileImage": profileImage
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                // 응답 처리
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Profile updated: \(responseString)")
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
