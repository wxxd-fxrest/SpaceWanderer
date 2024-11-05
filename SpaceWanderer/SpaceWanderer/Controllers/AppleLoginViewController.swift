//
//  AppleLoginViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/31/24.
//

import UIKit
import AuthenticationServices

class AppleLoginViewController: UIViewController {
    var userUniqueIdLabel: UILabel!
    let appleLoginManager = AppleLoginManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 앱 로딩 시 UserDefaults에서 저장된 userIdentifier로 로그인 상태 확인
        if let userIdentifier = appleLoginManager.getUserIdentifier() {
            print("userIdentifier 확인")
            print("userIdentifier 확인", userIdentifier)
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
extension AppleLoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true) // 뒤로가기
               }
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
