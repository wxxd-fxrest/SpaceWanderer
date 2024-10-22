//
//  ViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/18/24.
//

import UIKit
import AuthenticationServices

struct AppleLoginResponse {
    let userIdentifier: String?
    let refreshToken: String?
    let userUniqueId: String? // userUniqueId 추가
}

class AppleLoginManager {
    let userDefaults = UserDefaults.standard
    let backendURL: String = "http://localhost:1020/api/v1/auth/oauth2"

    // userIdentifier 저장
    func saveUserIdentifier(_ userIdentifier: String) {
        userDefaults.set(userIdentifier, forKey: "userIdentifier")
    }
    
    // userIdentifier 가져오기
    func getUserIdentifier() -> String? {
        return userDefaults.string(forKey: "userIdentifier")
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
                    DispatchQueue.main.async {
                        completion(accessToken, userUniqueId) // Access Token 및 userUniqueId 반환
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
}

class ViewController: UIViewController {
    var userUniqueIdLabel: UILabel!
    let appleLoginManager = AppleLoginManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 앱 로딩 시 UserDefaults에서 저장된 userIdentifier로 로그인 상태 확인
        if let userIdentifier = appleLoginManager.getUserIdentifier() {
            print("userIdentifier 확인")
            print("userIdentifier 확인", userIdentifier)
        }
        
        // 앱 로딩 시 자동 로그인 처리
        appleLoginManager.autoLogin { accessToken, userUniqueId in
            if let accessToken = accessToken, let userUniqueId = userUniqueId {
                print("Access Token: \(accessToken)")
                self.displayUserUniqueId(userUniqueId) // userUniqueId 표시
            } else {
                print("자동 로그인 실패")
            }
        }

        // 애플 로그인 버튼 추가
        let appleSignInButton = ASAuthorizationAppleIDButton()
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
        appleSignInButton.frame = CGRect(x: 50, y: 100, width: 200, height: 50)
        self.view.addSubview(appleSignInButton)

        // userUniqueId 표시할 라벨 추가
        userUniqueIdLabel = UILabel()
        userUniqueIdLabel.textAlignment = .center
        userUniqueIdLabel.textColor = .red
        userUniqueIdLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        userUniqueIdLabel.frame = CGRect(x: 50, y: 300, width: 300, height: 50)
        userUniqueIdLabel.isHidden = true
        self.view.addSubview(userUniqueIdLabel)
    }
    
    // userIdentifier를 화면에 표시
    func displayUserUniqueId(_ userIdentifier: String) {
        DispatchQueue.main.async {
            self.userUniqueIdLabel.text = "User ID: \(userIdentifier)" // userIdentifier로 수정
            self.userUniqueIdLabel.isHidden = false
        }
    }

    // 애플 로그인 요청 처리
    @objc func handleAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
}

// ASAuthorizationControllerDelegate 및 ASAuthorizationControllerPresentationContextProviding 준수
extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        guard let idToken = appleIDCredential.identityToken,
              let idTokenString = String(data: idToken, encoding: .utf8) else {
            return
        }

        var appleResponse: [String: Any] = [:]
        
        if let authorizationCodeData = appleIDCredential.authorizationCode,
           let authorizationCodeString = String(data: authorizationCodeData, encoding: .utf8) {
            appleResponse["authorizationCode"] = authorizationCodeString
        } else {
            print("authorizationCode를 가져오는 데 실패했습니다.")
        }
        
        appleResponse["email"] = appleIDCredential.email
        appleResponse["fullName"] = appleIDCredential.fullName?.givenName ?? ""
        appleResponse["familyName"] = appleIDCredential.fullName?.familyName ?? ""
        appleResponse["user"] = appleIDCredential.user

        guard let jsonData = try? JSONSerialization.data(withJSONObject: appleResponse, options: []),
              let appleResponseString = String(data: jsonData, encoding: .utf8) else {
            print("애플 응답 JSON 변환 오류")
            return
        }

        appleLoginManager.loginWithApple(idToken: idTokenString, appleResponse: appleResponseString) { response in
            if let userIdentifier = response.userIdentifier, let userUniqueId = response.userUniqueId {
                self.appleLoginManager.saveUserIdentifier(userIdentifier)
                print("로그인 성공, userIdentifier: \(userIdentifier), userUniqueId: \(userUniqueId)")
                self.displayUserUniqueId(userUniqueId) // userUniqueId를 화면에 표시
            } else {
                print("로그인 실패")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("로그인 오류: \(error.localizedDescription)")
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
