//
//  KakaoLoginManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/31/24.
//

import UIKit
import Foundation
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

protocol KakaoLoginManagerDelegate: AnyObject {
    func didRequestReLogin()
    func didCompleteAutoLogin()
}

protocol KakaoAutoLoginManagerDelegate: AnyObject {
    func didCompleteKakaoUpdate(userUniqueId: String, userIdentifier: String)
    func didCompleteKakaoLogin(userUniqueId: String, userIdentifier: String)
}

class KakaoLoginAPIManager {
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
    
    func attemptAutoLogin(completion: @escaping (String?) -> Void) {
        print("자동 로그인 시도")
        
        // UserDefaults에서 userIdentifier 가져오기
        if let userIdentifier = UserDefaults.standard.string(forKey: "kakaoUserIdentifier") {
            print("자동 로그인 시도: ", userIdentifier)
            
            // ✅ 유효한 토큰 검사
            if AuthApi.hasToken() {
                // 토큰이 존재하면 유효성 검사
                UserApi.shared.accessTokenInfo { (_, error) in
                    if let error = error {
                        if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                            // 토큰이 유효하지 않거나 만료됨, 재로그인 필요
                            print("토큰 만료, 재로그인 필요")
                            DispatchQueue.main.async {
                                self.showReLoginAlert() // 사용자에게 재로그인 요청
                            }
                            completion(nil)
                        } else {
                            // 기타 오류 처리
                            print("기타 오류 발생: \(error.localizedDescription)")
                            completion(nil)
                        }
                    } else {
                        // 토큰 유효성 체크 성공, 자동 로그인 진행
                        print("토큰 유효성 검사 성공")
                        // 백엔드에서 사용자 데이터 가져오기
                        self.fetchUserDataFromBackend(userIdentifier: userIdentifier) { userUniqueId, kakaoUserId in
                            // 자동 로그인 성공 후 클로저 호출
                            completion(userUniqueId)
                        }
                    }
                }
            } else {
                // 토큰이 존재하지 않음, 재로그인 필요
                print("토큰이 존재하지 않음, 재로그인 필요")
                DispatchQueue.main.async {
                    self.showReLoginAlert() // 사용자에게 재로그인 요청
                }
                completion(nil)
            }
        } else {
            // UserDefaults에 userIdentifier가 없으면 로그인 필요
            print("kakaoUserIdentifier가 UserDefaults에 저장되어 있지 않습니다.")
            completion(nil)
        }
    }
    
    private func fetchUserDataFromBackend(userIdentifier: String, completion: @escaping (String?, String?) -> Void) {
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
                            DispatchQueue.main.async {
                                self.autoDelegate?.didCompleteKakaoLogin(userUniqueId: userUniqueId, userIdentifier: userIdentifier)
                            }
                        } else {
                            // nickname이 nil이거나 비어있을 경우
                            print("닉네임이 존재하지 않거나 비어있습니다.")
                            DispatchQueue.main.async {
                                self.autoDelegate?.didCompleteKakaoUpdate(userUniqueId: userUniqueId, userIdentifier: userIdentifier)
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
    
    func sendUserInfoToBackend(userIdentifier: String, email: String, refreshToken: String, loginType: String) {
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
            "destinationPlanet": "수성",
            "dayGoalCount": 0,
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
                // 로그아웃이 정상적으로 완료된 후에 UserDefaults에서 데이터 삭제
                DispatchQueue.main.async {
                    // UserDefaults에서 kakaoUserIdentifier 삭제
                    UserDefaults.standard.removeObject(forKey: "kakaoUserIdentifier")
                    UserDefaults.standard.removeObject(forKey: "LoginType")
                    
                    UserDefaults.standard.removeObject(forKey: "lastNotificationDate")
                    UserDefaults.standard.removeObject(forKey: "notificationSentFor8k")
                    UserDefaults.standard.removeObject(forKey: "notificationSentFor10k")
                    
                    // UserDefaults 변경 사항 저장
                    UserDefaults.standard.synchronize()
                    
                    print("로그아웃 성공")
                    completion(true)
                }
            }
        }
    }
    
    // 사용자 데이터 삭제를 위한 백엔드 요청
    func deleteUserDataFromBackend(userIdentifier: String, completion: @escaping (Bool) -> Void) {
        // 서버에서 사용자 데이터를 삭제하는 API 호출 (예시)
        guard let url = URL(string: "\(backendURL)/kakao-delete/\(userIdentifier)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("백엔드 사용자 데이터 삭제 실패: \(error)")
                completion(false)
                return
            }
            
            // 서버에서 성공적으로 데이터를 삭제했을 때
            if let data = data, let _ = String(data: data, encoding: .utf8) {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
}

