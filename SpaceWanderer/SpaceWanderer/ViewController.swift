//
//  ViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/18/24.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices

class ViewController: UIViewController, KakaoAutoLoginManagerDelegate, AppleAutoLoginManagerDelegate, KakaoLoginManagerDelegate {

    private let loginView = LoginView()
    private let kakaoLoginManager = KakaoLoginAPIManager() // KakaoLoginManager 인스턴스 생성
    private let appleLoginManager = AppleAPILoginManager() // AppleLoginManager 인스턴스 생성

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.PupleColor
        addStars(starCount: 100)
        
        // Delegate 설정
        kakaoLoginManager.autoDelegate = self
        appleLoginManager.autoDelegate = self
        kakaoLoginManager.delegate = self
        
        // UI 세팅
        setupUI()
        
        // MARK: Check
        KeychainHelper.shared.printValue(for: "appleUserIdentifier")
        KeychainHelper.shared.printValue(for: "kakaoUserIdentifier")
        
        if let LoginType = UserDefaults.standard.string(forKey: "LoginType") {
            print("저장된 LoginType: \(LoginType)")
        }
        
        // 앱 로딩 시 UserDefaults에서 저장된 userIdentifier로 로그인 상태 확인
        if let userIdentifier = appleLoginManager.getUserIdentifier() {
            print("userIdentifier 확인", userIdentifier)
        }
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        autoLoginIfNeeded() // 여기에서 호출
    }
    
    private func setupUI() {
        loginView.frame = view.bounds
        loginView.appleSignInButtonTapped = { [weak self] in
            self?.handleAppleSignIn()
        }
        loginView.kakaoLoginButtonTapped = { [weak self] in
            self?.handleKakaoLogin()
        }
        view.addSubview(loginView)
    }
    
    // MARK: - Kakao Button Click Event
    func handleKakaoLogin() {
        loginView.startLoading() // 로딩 인디케이터 시작
        loginView.hideLoginButtons() // 로그인 버튼 숨기기
        
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 오류: \(error)")
                    self.loginView.showLoginButtons()
                } else if let oauthToken = oauthToken {
                    print("카카오톡 로그인 성공")
                    self.handleKakaoUserInfo(oauthToken: oauthToken)
                }
                self.loginView.stopLoading() // 로딩 인디케이터 중지
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오 계정 로그인 오류: \(error)")
                    self.loginView.showLoginButtons()
                } else if let oauthToken = oauthToken {
                    print("카카오 계정 로그인 성공")
                    self.handleKakaoUserInfo(oauthToken: oauthToken)
                }
                self.loginView.stopLoading() // 로딩 인디케이터 중지
            }
        }
    }
    
    private func handleKakaoUserInfo(oauthToken: OAuthToken) {
        UserApi.shared.me { (user, error) in
            if let error = error {
                print("사용자 정보 조회 오류: \(error)")
            } else if let user = user {
                if let userId = user.id {
                    print("사용자 식별자 (id): \(userId)")
                    UserDefaults.standard.set("\(userId)", forKey: "kakaoUserIdentifier")
                    let email = user.kakaoAccount?.email ?? "이메일 권한 없음"
                    let refreshToken = oauthToken.refreshToken
                    let loginType = "kakao"
                    self.kakaoLoginManager.sendUserInfoToBackend(userIdentifier: "\(userId)", email: email, refreshToken: refreshToken, loginType: loginType)
                }
            }
        }
    }
    
    // MARK: - Apple Button Click Event
    func handleAppleSignIn() {
        print("click apple login button")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }

    // MARK: - KAKAO LOGIN VIEW CONTROLLER
    // Delegate 메서드 구현
    func didRequestReLogin() {
        handleKakaoLogin() // 재로그인 프로세스 시작
    }
    
    // 자동로그인 후 Main View로 이동
    func didCompleteAutoLogin() {
        self.autoLoginIfNeeded()
    }
    
    // 자동로그인 후 Main View로 이동
    func didCompleteKakaoLogin(userUniqueId: String, userIdentifier: String) {
        print("이동 전", userUniqueId, userIdentifier)
        let mainVC = TabBarViewController(userUniqueId: userUniqueId, userIdentifier: userIdentifier)
        navigationController?.pushViewController(mainVC, animated: true)
        print("이동 후")
    }

    func didCompleteKakaoUpdate(userUniqueId: String, userIdentifier: String) {
        print("이동 전")
        let updateProfileVC = UpdateProfileViewController()
        updateProfileVC.userUniqueId = userUniqueId // userUniqueId 전달
        updateProfileVC.userIdentifier = userIdentifier // userIdentifier 전달
        navigationController?.pushViewController(updateProfileVC, animated: true)
        print("이동 후")
    }
    
    func didCompleteAppleLogin(userUniqueId: String, userIdentifier: String, accessToken: String?) {
        print("이동 전", userUniqueId, userIdentifier)
        let mainVC = TabBarViewController(userUniqueId: userUniqueId, userIdentifier: userIdentifier)
        navigationController?.pushViewController(mainVC, animated: true)
        print("이동 후")
    }

    func didCompleteAppleUpdate(userUniqueId: String, userIdentifier: String, accessToken: String?) {
        print("이동 전")
        let updateProfileVC = UpdateProfileViewController()
        updateProfileVC.userUniqueId = userUniqueId // userUniqueId 전달
        updateProfileVC.userIdentifier = userIdentifier // userIdentifier 전달
        navigationController?.pushViewController(updateProfileVC, animated: true)
        print("이동 후")
    }

    private func autoLoginIfNeeded() {
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            print("저장된 로그인 타입: \(loginType)")
            loginView.startLoading() // 로딩 인디케이터 시작
            loginView.hideLoginButtons() // 로그인 버튼 숨기기
            
            if loginType == "LOGIN_KAKAO" {
                kakaoLoginManager.attemptAutoLogin { userUniqueId in
                    self.loginView.stopLoading() // 로딩 인디케이터 중지
                    if let userUniqueId = userUniqueId {
                        print("kakaoLoginManager Access Token")
                    } else {
                        print("자동 로그인 실패")
                        self.loginView.showLoginButtons() // 로그인 버튼 보이기
                    }
                }
            } else if loginType == "LOGIN_APPLE" {
                appleLoginManager.autoLogin { accessToken, userUniqueId in
                    self.loginView.stopLoading() // 로딩 인디케이터 중지
                    if let userUniqueId = userUniqueId {
                        print("appleLoginManager Access Token: \(accessToken)")
                    } else {
                        print("자동 로그인 실패")
                        self.loginView.showLoginButtons() // 로그인 버튼 보이기
                    }
                }
            } else {
                // 자동 로그인 시도 전 로그인 버튼 보이기
                loginView.showLoginButtons()
            }
        }
    }
}

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
                
                DispatchQueue.main.async {
                    self.didCompleteAutoLogin()
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
