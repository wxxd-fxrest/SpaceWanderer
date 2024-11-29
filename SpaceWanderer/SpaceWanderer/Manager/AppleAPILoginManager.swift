//
//  AppleLoginManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/31/24.
//

import Foundation

protocol AppleAutoLoginManagerDelegate: AnyObject {
    func didCompleteAppleUpdate(userUniqueId: String, userIdentifier: String, accessToken: String?)
    func didCompleteAppleLogin(userUniqueId: String, userIdentifier: String, accessToken: String?)
}

class AppleAPILoginManager {
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
    func loginWithApple(idToken: String, appleResponse: String, completion: @escaping (AppleLoginModel) -> Void) {
        let url = URL(string: "\(backendURL)/apple-login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["idToken": idToken, "appleResponse": appleResponse]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("서버 오류: \(error.localizedDescription)")
                completion(AppleLoginModel(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
                return
            }

            guard let data = data else {
                print("데이터가 없습니다.")
                completion(AppleLoginModel(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("datadata ", data)

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

                        completion(AppleLoginModel(userIdentifier: userIdentifier, refreshToken: nil, userUniqueId: userUniqueId))
                    } else {
                        print("userIdentifier 또는 userUniqueId가 없습니다.")
                        completion(AppleLoginModel(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
                    }
                } else {
                    print("유효하지 않은 JSON 형식입니다.")
                    completion(AppleLoginModel(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
                }
            } catch {
                print("JSON 파싱 오류: \(error.localizedDescription)")
                completion(AppleLoginModel(userIdentifier: nil, refreshToken: nil, userUniqueId: nil))
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
        
        guard let url = URL(string: "\(backendURL)/apple-auto-login") else { return }
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
                    
                    // nickname 가져오기
                    let nickname = json["nickname"] as? String
                    
                    // nickname이 nil인지 체크
                    if let nickname = nickname, !nickname.isEmpty {
                        // nickname이 존재할 경우
                        print("닉네임이 존재합니다: \(nickname)")
                        // 여기 MainVC로 이동하는 함수 추가
                        DispatchQueue.main.async {
                            self.autoDelegate?.didCompleteAppleLogin(userUniqueId: userUniqueId, userIdentifier: userIdentifier, accessToken: accessToken)
                        }
                    } else {
                        // nickname이 nil이거나 비어있을 경우
                        print("닉네임이 존재하지 않거나 비어있습니다.")
                        // 여기 UpdateVC로 이동하는 함수 추가
                        DispatchQueue.main.async {
                            self.autoDelegate?.didCompleteAppleUpdate(userUniqueId: userUniqueId, userIdentifier: userIdentifier, accessToken: accessToken)
                        }
                    }
                        
                    completion(accessToken, userUniqueId) // Access Token 및 userUniqueId 반환
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
        
        // 삭제된 값 확인 로그
        if userDefaults.object(forKey: "appleUserIdentifier") == nil {
            print("애플 사용자 식별자 삭제 완료")
        } else {
            print("애플 사용자 식별자 삭제 실패")
        }

        if userDefaults.object(forKey: "LoginType") == nil {
            print("로그인 타입 삭제 완료")
        } else {
            print("로그인 타입 삭제 실패")
        }
        
        print("애플 로그아웃 성공")
    }
    
    // 애플 회원 탈퇴 
    func deleteUserAccount(userIdentifier: String, accessToken: String?, completion: @escaping (Bool, String) -> Void) {
        print("deleteUserAccount userIdentifier: ", userIdentifier)
        guard let url = URL(string: "\(backendURL)/apple-delete/\(userIdentifier)") else {
            completion(false, "잘못된 URL입니다.")
            return
        }
        
        var request = URLRequest(url: url)
        print("deleteUserAccount url: ", url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = ["userIdentifier": userIdentifier]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, "서버와의 연결에 실패했습니다: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, "서버 응답을 받지 못했습니다.")
                }
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("서버 응답: \(responseString)")
                
                if responseString.contains("회원 탈퇴가 완료되었습니다.") {
                    DispatchQueue.main.async {
                        completion(true, responseString)
                    }
                } else {
                    let errorMessage = "서버에서 예상치 못한 응답을 받았습니다: \(responseString)"
                    DispatchQueue.main.async {
                        completion(false, errorMessage)
                    }
                }
            }
        }
        
        task.resume()
    }
}
