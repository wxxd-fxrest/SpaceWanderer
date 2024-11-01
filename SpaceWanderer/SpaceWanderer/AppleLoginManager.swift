//
//  AppleLoginManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/31/24.
//

import Foundation

protocol AppleAutoLoginManagerDelegate: AnyObject {
    func didCompleteLogin(userUniqueId: String, userIdentifier: String, accessToken: String)
}

class AppleLoginManager {
    let userDefaults = UserDefaults.standard
    weak var autoDelegate: AppleAutoLoginManagerDelegate?
    
    lazy var backendURL: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["AUTH_BASE_URL"] as? String {
            print("AUTH_BASE_URL", backendURL)

            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()

    // userIdentifier 저장
    func saveUserIdentifier(_ userIdentifier: String) {
        UserDefaults.standard.set(userIdentifier, forKey: "appleUserIdentifier")
    }
    
    // userIdentifier 가져오기
    func getUserIdentifier() -> String? {
        return UserDefaults.standard.string(forKey: "appleUserIdentifier")
    }
    
    // 애플 로그인 처리 및 백엔드에 idToken 전송
    func loginWithApple(idToken: String, appleResponse: String, completion: @escaping (AppleLoginResponse) -> Void) {
        let url = URL(string: "\(backendURL)/apple-login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["idToken": idToken, "appleResponse": appleResponse]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("서버 오류: \(error.localizedDescription)")
                completion(AppleLoginResponse(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
                return
            }

            guard let data = data else {
                print("데이터가 없습니다.")
                completion(AppleLoginResponse(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let userIdentifier = json["userIdentifier"] as? String
                    let userUniqueId = json["userUniqueId"] as? String
                    
                    if let userIdentifier = userIdentifier, let userUniqueId = userUniqueId {
                        print("로그인 성공, userIdentifier: \(userIdentifier), userUniqueId: \(userUniqueId)")
                        
                        // userIdentifier를 UserDefaults에 저장
                        self.saveUserIdentifier(userIdentifier) // userIdentifier 저장
                        print("UserDefaults에 userIdentifier 저장 완료")
                        
                        // "AppleLogin" 문자열을 UserDefaults에 저장
                        UserDefaults.standard.set("LOGIN_APPLE", forKey: "LoginType")
                        print("UserDefaults에 'LOGIN_APPLE' 저장 완료")

                        completion(AppleLoginResponse(userIdentifier: userIdentifier, refreshToken: nil, userUniqueId: userUniqueId))
                    } else {
                        print("userIdentifier 또는 userUniqueId가 없습니다.")
                        completion(AppleLoginResponse(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
                    }
                } else {
                    print("유효하지 않은 JSON 형식입니다.")
                    completion(AppleLoginResponse(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
                }
            } catch {
                print("JSON 파싱 오류: \(error.localizedDescription)")
                completion(AppleLoginResponse(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
            }
        }
        task.resume()
    }

    // 자동 로그인 처리
    func autoLogin(completion: @escaping (String?, String?) -> Void) {
        guard let userIdentifier = getUserIdentifier() else {
            completion(nil, nil)
            return
        }
        
        guard let url = URL(string: "\(backendURL)/auto-login") else { return }
        var request = URLRequest(url: url)
        print(url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 요청 본문 설정
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["userIdentifier": userIdentifier])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("서버 오류: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP 상태 코드: \(httpResponse.statusCode)") // 상태 코드 로그 추가
            }

            guard let data = data else {
                print("데이터가 없습니다.")
                completion(nil, nil)
                return
            }
            
            // 응답 데이터 로그 추가
            let responseString = String(data: data, encoding: .utf8)
            print("응답 데이터: \(responseString ?? "데이터 변환 실패")")
            
            // JSON 파싱 및 Access Token 및 userUniqueId 추출
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["accessToken"] as? String,
                   let userUniqueId = json["userUniqueId"] as? String {
                    completion(accessToken, userUniqueId) // Access Token 및 userUniqueId 반환

                    DispatchQueue.main.async {
                        self.autoDelegate?.didCompleteLogin(userUniqueId: userUniqueId, userIdentifier: userIdentifier, accessToken: accessToken)
                    }
                } else {
                    print("응답 데이터가 예상한 형식이 아닙니다.")
                    completion(nil, nil)
                }
            } catch {
                print("JSON 파싱 오류: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }
        task.resume()
    }
    
    // 로그아웃 처리
    func logout() {
        // UserDefaults에서 애플 사용자 정보 삭제
        userDefaults.removeObject(forKey: "appleUserIdentifier")
        userDefaults.removeObject(forKey: "LoginType")
        
        // 필요 시 추가적인 정리 작업 수행
        print("애플 로그아웃 성공")
    }
}
