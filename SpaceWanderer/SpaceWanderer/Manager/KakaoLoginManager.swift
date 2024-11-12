//
//  KakaoLoginManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/31/24.
//

import UIKit
import Foundation
import KakaoSDKUser

protocol KakaoLoginManagerDelegate: AnyObject {
    func didRequestReLogin()
    func didCompleteAutoLogin()
}

protocol KakaoAutoLoginManagerDelegate: AnyObject {
    func didCompleteUpdate(userUniqueId: String, userIdentifier: String, accessToken: String)
    func didCompleteLogin(userUniqueId: String, userIdentifier: String, accessToken: String)
}

class KakaoLoginManager {
    weak var delegate: KakaoLoginManagerDelegate?
    weak var autoDelegate: KakaoAutoLoginManagerDelegate?
    
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

    func printBackendURL() {
        print("Backend URL: \(backendURL)")
    }
    
    func attemptAutoLogin(completion: @escaping (String?, String?) -> Void) {
        print("자동 로그인 시도")
        
        // UserDefaults에서 userIdentifier 가져오기
        if let userIdentifier = UserDefaults.standard.string(forKey: "kakaoUserIdentifier") {
            print("자동 로그인 시도: ", userIdentifier)
            fetchUserDataFromBackend(userIdentifier: userIdentifier) { accessToken, userUniqueId, kakaoUserId in
                // 백엔드에서 사용자 데이터 가져오기 완료 후 클로저 호출
                completion(accessToken, userUniqueId)
            }
        } else {
            print("kakaoUserIdentifier가 UserDefaults에 저장되어 있지 않습니다.")
            // 실패 시 nil 반환
            completion(nil, nil)
        }
    }
    
    private func fetchUserDataFromBackend(userIdentifier: String, completion: @escaping (String?, String?, String?) -> Void) {
        guard let url = URL(string: "\(backendURL)/get-kakao-user/\(userIdentifier)?limit=10") else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("사용자 데이터를 가져오는 중 오류 발생: \(error)")
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("유효하지 않은 응답")
                return
            }

            guard (200...299).contains(response.statusCode) else {
                print("Server error: \(response.statusCode)")
                return
            }

            guard let data = data, !data.isEmpty else {
                print("서버에서 빈 데이터를 받았습니다.")
                return
            }

            do {
                if let userData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("사용자 데이터 가져오기 성공: \(userData)")
                    
                    if let refreshToken = userData["refreshToken"] as? String,
                       let userUniqueId = userData["userUniqueId"] as? String {
                        print("refreshToken | ", refreshToken)

                        // nickname 가져오기
                        let nickname = userData["nickname"] as? String
                        
                        // nickname이 nil인지 체크
                        if let nickname = nickname, !nickname.isEmpty {
                            // nickname이 존재할 경우
                            print("닉네임이 존재합니다: \(nickname)")
                            // Access Token을 가져오는 함수 호출
                            self.getAccessToken(refreshToken: refreshToken, userIdentifier: userIdentifier, userUniqueId: userUniqueId) { accessToken in
                                guard let accessToken = accessToken else {
                                    print("Access Token을 가져오지 못했습니다.")
                                    return
                                }
                                
                                print("Access Token을 가져옴.")
                                // 여기 MainVC로 이동하는 함수 추가
                                DispatchQueue.main.async {
                                    self.autoDelegate?.didCompleteLogin(userUniqueId: userUniqueId, userIdentifier: userIdentifier, accessToken: accessToken)
                                }
                            }
                        } else {
                            // nickname이 nil이거나 비어있을 경우
                            print("닉네임이 존재하지 않거나 비어있습니다.")
                            self.getAccessToken(refreshToken: refreshToken, userIdentifier: userIdentifier, userUniqueId: userUniqueId) { accessToken in
                                guard let accessToken = accessToken else {
                                    print("Access Token을 가져오지 못했습니다.")
                                    return
                                }
                                
                                print("Access Token을 가져옴.")
                                // 여기 UpdateVC로 이동하는 함수 추가
                                DispatchQueue.main.async {
                                    self.autoDelegate?.didCompleteUpdate(userUniqueId: userUniqueId, userIdentifier: userIdentifier, accessToken: accessToken)
                                }
                            }
                        }
                    }
                }
            } catch {
                print("JSON 파싱 중 오류 발생: \(error)")
            }
        }
        task.resume()
    }
    
    func getAccessToken(refreshToken: String, userIdentifier: String, userUniqueId: String, completion: @escaping (String?) -> Void) {
        print("Access Token 가져오기")
        print("getAccessToken | userUniqueId: \(userUniqueId), refreshToken: \(refreshToken), userIdentifier: \(userIdentifier)")
        guard let url = URL(string: "\(backendURL)/get-kakao-access-token") else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["refreshToken": refreshToken]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("매개변수를 JSON으로 변환하는 중 오류 발생: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Access Token 가져오는 중 오류 발생: \(error)")
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("유효하지 않은 응답")
                return
            }

            guard (200...299).contains(response.statusCode) else {
                print("Server error: \(response.statusCode)")
                if response.statusCode == 401 { // Unauthorized error
                    DispatchQueue.main.async {
                        self.showReLoginAlert() // 재로그인 알림 표시
                    }
                }
                return
            }

            guard let data = data else {
                print("서버에서 빈 데이터를 받았습니다.")
                return
            }

            do {
                if let tokenResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = tokenResponse["access_token"] as? String {
                    print("Access Token: \(accessToken)")
                    completion(accessToken)
                } else {
                    completion(nil) // Access Token을 가져오는 데 실패한 경우
                }
            } catch {
                print("JSON 파싱 중 오류 발생: \(error)")
            }
        }
        task.resume()
    }

    private func showReLoginAlert() {
        let alert = UIAlertController(title: "재로그인 필요", message: "토큰이 만료되었습니다. 다시 로그인해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            // delegate를 통해 재로그인 요청
            self.delegate?.didRequestReLogin()
        }))
        
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendUserInfoToBackend(userIdentifier: String, email: String, refreshToken: String, loginType: String, accessToken: String) {
        guard let url = URL(string: "\(backendURL)/kakao-login") else { return }
        var request = URLRequest(url: url)
        print("sendUserInfoToBackend: ", url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "userIdentifier": userIdentifier,
            "email": email,
            "refreshToken": refreshToken,
            "loginType": loginType,
            "inhabitedPlanet": "천행성",
            "dayGoalCount": 0,
            "destinationPlanet": "지구"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("매개변수를 JSON으로 변환하는 중 오류 발생: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("사용자 정보를 보내는 중 오류 발생: \(error)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("유효하지 않은 응답")
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print("Server error: \(response.statusCode)")
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("서버에서 빈 데이터를 받았습니다.")
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("서버로부터의 응답: \(String(describing: jsonResponse))")

                // JSON 응답에서 userUniqueId 추출
                if let jsonResponse = jsonResponse,
                   let userUniqueId = jsonResponse["userUniqueId"] as? String,
                   let refreshToken = jsonResponse["refreshToken"] as? String {
                    UserDefaults.standard.set("LOGIN_KAKAO", forKey: "LoginType")
                    print("UserDefaults에 'LOGIN_KAKAO' 저장 완료")
                    // 불러오기
                    if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
                        print("Login Type: \(loginType)")  // 출력: Login Type: LOGIN_KAKAO
                    }
                                        
                    print("sendUserInfoToBackend | refreshToken: \(refreshToken), userUniqueId: \(userUniqueId), userIdentifier: \(userIdentifier)")
                    
                    // 뒤로가기 요청
                    DispatchQueue.main.async {
                         self.delegate?.didCompleteAutoLogin() // Delegate를 통해 로그인 완료 알림
                     }
                }
            } catch {
                print("JSON 파싱 중 오류 발생: \(error)")
            }
        }
        task.resume()
    }
    
    // 로그아웃 처리
    func logout(completion: @escaping (Bool) -> Void) {
        UserApi.shared.logout { (error) in
            if let error = error {
                print("로그아웃 오류: \(error)")
                completion(false)
            } else {
                print("로그아웃 성공")
                // UserDefaults에서 kakaoUserIdentifier 삭제
                UserDefaults.standard.removeObject(forKey: "kakaoUserIdentifier")
                UserDefaults.standard.removeObject(forKey: "LoginType")
                completion(true)
            }
        }
    }
}
