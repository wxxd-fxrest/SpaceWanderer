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

class ViewController: UIViewController,  KakaoAutoLoginManagerDelegate, AppleAutoLoginManagerDelegate, KakaoLoginManagerDelegate {
    
    let kakaoLoginManager = KakaoLoginManager() // KakaoLoginManager 인스턴스 생성
    let appleLoginManager = AppleLoginManager() // AppleLoginManager 인스턴스 생성

    let kakaoLoginButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kakaoLoginManager.autoDelegate = self
        appleLoginManager.autoDelegate = self
        
        kakaoLoginManager.delegate = self
        
        // 배경 색상 설정
        view.backgroundColor = SpecialColors.PupleColor
        
        // 별 추가
        addStars()
        
        // 중앙에 이미지 추가
        addCenterImage()
        
        //MARK: Check
//        KeychainHelper.shared.deleteValue(for: "appleUserIdentifier")
//        KeychainHelper.shared.deleteValue(for: "kakaoUserIdentifier")
        KeychainHelper.shared.printValue(for: "appleUserIdentifier")
        KeychainHelper.shared.printValue(for: "kakaoUserIdentifier")

        // UserDefaults에서 저장된 값 출력
         if let LoginType = UserDefaults.standard.string(forKey: "LoginType") {
             print("저장된 LoginType: \(LoginType)")
         } else {
             print("저장된 LoginType 식별자가 없습니다.")
         }
         
        // UserDefaults에서 저장된 값 출력
         if let appleUserIdentifier = UserDefaults.standard.string(forKey: "appleUserIdentifier") {
             print("저장된 apple 사용자 식별자: \(appleUserIdentifier)")
         } else {
             print("저장된 apple 사용자 식별자가 없습니다.")
         }
        
        // UserDefaults에서 저장된 값 출력
         if let kakaoUserIdentifier = UserDefaults.standard.string(forKey: "kakaoUserIdentifier") {
             print("저장된 Kakao 사용자 식별자: \(kakaoUserIdentifier)")
         } else {
             print("저장된 Kakao 사용자 식별자가 없습니다.")
         }
        
        // MARK: KAKAO LOGIN BUTTON
        setupKakaoLoginButton()
        
        // MARK: APPLE LOGIN
        // 앱 로딩 시 UserDefaults에서 저장된 userIdentifier로 로그인 상태 확인
        if let userIdentifier = appleLoginManager.getUserIdentifier() {
            print("userIdentifier 확인")
            print("userIdentifier 확인", userIdentifier)
        }
        
        // 애플 로그인 버튼 추가
        setupAppleSignInButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        autoLoginIfNeeded() // 여기에서 호출
        
        printMemoryUsage()
    }
    func printMemoryUsage() {
        let memoryUsage = report_memory()
        print("Memory usage: \(memoryUsage) MB")
    }

    func report_memory() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Double(taskInfo.resident_size) / 1024.0 / 1024.0 // MB 단위
        } else {
            print("Error with task_info: \(kerr)")
            return -1
        }
    }
    
    // 자동 로그인 처리
    private func autoLoginIfNeeded() {
        // UserDefaults에서 LoginType 읽어오기
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            print("저장된 로그인 타입: \(loginType)")
            
            if loginType == "LOGIN_KAKAO" {
                // Kakao 자동 로그인 시도
                kakaoLoginManager.attemptAutoLogin { userUniqueId in
                    if let userUniqueId = userUniqueId {
                        print("kakaoLoginManager Access Token")
                    } else {
                        print("자동 로그인 실패")
                    }
                }
            } else if loginType == "LOGIN_APPLE" {
                // Apple 자동 로그인 처리
                appleLoginManager.autoLogin { accessToken, userUniqueId in
                    if let userUniqueId = userUniqueId {
                        print("appleLoginManager Access Token: \(accessToken)")
                    } else {
                        print("자동 로그인 실패")
                    }
                }
            } else {
                print("알 수 없는 로그인 타입: \(loginType)")
            }
        } else {
            print("저장된 로그인 타입이 없습니다.")
        }
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
    
    // userUniqueId를 화면에 표시하는 메서드
    func displayUserUniqueId(_ userUniqueId: String) {
        print("User Unique ID: \(userUniqueId)")
    }

    func addStars() {
        let starCount = 100
        // 세 가지 색상 정의
        let colors: [UIColor] = [
            SpecialColors.PinkStarColor,      // 첫 번째 색상
            SpecialColors.BlueStarColor,      // 두 번째 색상
            SpecialColors.GreenStarColor,     // 세 번째 색상
            SpecialColors.WhiteStarColor      // 네 번째 색상
        ]
        
        for _ in 0..<starCount {
            let starSize: CGFloat = CGFloat.random(in: 1...6)
            let star = UIView(frame: CGRect(x: CGFloat.random(in: 0...view.bounds.width),
                                            y: CGFloat.random(in: 0...view.bounds.height),
                                            width: starSize,
                                            height: starSize))
            // 랜덤 색상 선택
            star.backgroundColor = colors.randomElement() // 배열에서 랜덤 색상 선택
            star.layer.cornerRadius = starSize / 2
            view.addSubview(star)
        }
    }
    
    private func addCenterImage() {
        let centerImageView = UIImageView()
        centerImageView.image = UIImage(named: "LaunchScreenIcon") // Assets에 있는 이미지 이름으로 변경
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerImageView)
        
        // 제약조건 설정
        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerImageView.widthAnchor.constraint(equalToConstant: 200), // 원하는 너비
            centerImageView.heightAnchor.constraint(equalToConstant: 200) // 원하는 높이
        ])
    }
    
    // MARK: - KAKAO LOGIN VIEW CONTROLLER
    // Delegate 메서드 구현
    func didRequestReLogin() {
        handleKakaoLogin() // 재로그인 프로세스 시작
    }
    
    private func setupKakaoLoginButton() {
        // 버튼 생성 및 속성 설정
        kakaoLoginButton.setTitle("카카오 로그인", for: .normal)
        kakaoLoginButton.setTitleColor(.black, for: .normal)
        kakaoLoginButton.backgroundColor = UIColor(red: 1.0, green: 0.88, blue: 0.12, alpha: 1.0) // 카카오톡 색상
        kakaoLoginButton.layer.cornerRadius = 8
        kakaoLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        kakaoLoginButton.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        
        // 버튼 레이아웃 설정
        kakaoLoginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(kakaoLoginButton)
        
        // 버튼 위치 제약 설정 (화면 중앙)
        NSLayoutConstraint.activate([
            kakaoLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            kakaoLoginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 160),  // Adjust this value as needed
            kakaoLoginButton.widthAnchor.constraint(equalToConstant: 200),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
    
    // MARK: - Test kakao talk & kakao account login
    @objc private func handleKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 오류: \(error)")
                } else if let oauthToken = oauthToken {
                    print("카카오톡 로그인 성공")
//                    self.requestAdditionalAgreement()
                    print("Refresh Token: \(oauthToken.refreshToken)")
                    print("Expires In: \(oauthToken.expiresIn) 초")
                    print("Refresh Token Expires In: \(oauthToken.refreshTokenExpiresIn) 초")
                    
                    UserApi.shared.me { (user, error) in
                        if let error = error {
                            print("사용자 정보 조회 오류: \(error)")
                        } else if let user = user {
                            if let userId = user.id {
                                print("사용자 식별자 (id): \(userId)")
                                
                                // UserDefaults에 사용자 식별자 저장
                                UserDefaults.standard.set("\(userId)", forKey: "kakaoUserIdentifier")
                                
                                let email = user.kakaoAccount?.email ?? "이메일 권한 없음"
                                let refreshToken = oauthToken.refreshToken
                                let loginType = "kakao"
                                let userUniqueId = "\(userId)" // 이 부분을 실제로 사용할 userUniqueId로 수정
//                                let accessToken = oauthToken.accessToken // accessToken도 oauthToken에서 가져옴
                                
                                self.kakaoLoginManager.sendUserInfoToBackend(userIdentifier: "\(userId)", email: email, refreshToken: refreshToken, loginType: loginType)
                            }
                        }
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오 계정 로그인 오류: \(error)")
                } else if let oauthToken = oauthToken {
                    print("카카오 계정 로그인 성공")
//                    self.requestAdditionalAgreement()
//                    print("Access Token: \(oauthToken.accessToken)")
                    print("Refresh Token: \(oauthToken.refreshToken)")
                    print("Expires In: \(oauthToken.expiresIn) 초")
                    print("Refresh Token Expires In: \(oauthToken.refreshTokenExpiresIn) 초")
                    
                    UserApi.shared.me { (user, error) in
                        if let error = error {
                            print("사용자 정보 조회 오류: \(error)")
                        } else if let user = user {
                            if let userId = user.id {
                                print("사용자 식별자 (id): \(userId)")
                                
                                // UserDefaults에 사용자 식별자 저장
                                UserDefaults.standard.set("\(userId)", forKey: "kakaoUserIdentifier")
                                
                                let email = user.kakaoAccount?.email ?? "이메일 권한 없음"
                                let refreshToken = oauthToken.refreshToken
                                let loginType = "kakao"
                                
//                                let accessToken = oauthToken.accessToken // accessToken도 oauthToken에서 가져옴
                                
                                self.kakaoLoginManager.sendUserInfoToBackend(userIdentifier: "\(userId)", email: email, refreshToken: refreshToken, loginType: loginType)
                            }
                        }
                    }
                }
            }
        }
    }
    // MARK: - only kakao talk login
//    @objc private func handleKakaoLogin() {
//        UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
//            if let error = error {
//                print("카카오톡 로그인 오류: \(error)")
//                self.showKakaoTalkInstallAlert()
//            } else if let oauthToken = oauthToken {
//                print("카카오톡 로그인 성공")
//                self.handleLoginSuccess(oauthToken: oauthToken)
//            }
//        }
//    }
//
//    private func showKakaoTalkInstallAlert() {
//        let alert = UIAlertController(title: "카카오톡 설치 필요", message: "카카오톡 로그인을 위해 카카오톡 앱이 설치되어 있어야 합니다. 설치하시겠습니까?", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "앱 스토어로 이동", style: .default, handler: { _ in
//            if let url = URL(string: "https://apps.apple.com/kr/app/kakaotalk/id362057947") {
//                UIApplication.shared.open(url)
//            }
//        }))
//
//        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
//
//        if let topController = UIApplication.shared.windows.first?.rootViewController {
//            topController.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    private func handleLoginSuccess(oauthToken: OAuthToken) {
//        self.requestAdditionalAgreement()
//        print("Access Token: \(oauthToken.accessToken)")
//        print("Refresh Token: \(oauthToken.refreshToken)")
//        print("Expires In: \(oauthToken.expiresIn) 초")
//        print("Refresh Token Expires In: \(oauthToken.refreshTokenExpiresIn) 초")
//
//        UserApi.shared.me { (user, error) in
//            if let error = error {
//                print("사용자 정보 조회 오류: \(error)")
//            } else if let user = user {
//                if let userId = user.id {
//                    print("사용자 식별자 (id): \(userId)")
//
//                    UserDefaults.standard.set("\(userId)", forKey: "kakaoUserIdentifier")
//
//                    let email = user.kakaoAccount?.email ?? "이메일 권한 없음"
//                    let refreshToken = oauthToken.refreshToken
//                    let loginType = "kakao"
//                    let accessToken = oauthToken.accessToken
//
//                    self.kakaoLoginManager.sendUserInfoToBackend(userIdentifier: "\(userId)", email: email, refreshToken: refreshToken, loginType: loginType, accessToken: accessToken)
//                }
//            }
//        }
//    }

//    private func requestAdditionalAgreement() {
//        UserApi.shared.accessTokenInfo { (accessTokenInfo, error) in
//            if let error = error {
//                print("Access Token 오류: \(error)")
//            } else if let accessTokenInfo = accessTokenInfo {
//                print("Access Token 정보: \(accessTokenInfo)")
//            }
//        }
//    }
    
    // 최초 로그인 후 main 화면으로 뒤로가기
    func didCompleteAutoLogin() {
        self.autoLoginIfNeeded()
    }
    
    // MARK: - APPLE LOGIN VIEW CONTROLLER
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

    private func setupAppleSignInButton() {
        let appleSignInButton = UIButton(type: .system)
        appleSignInButton.setTitle("Sign in with Apple", for: .normal)
        appleSignInButton.setTitleColor(.black, for: .normal) // Text color
        appleSignInButton.backgroundColor = .white // White background
        appleSignInButton.layer.cornerRadius = 10 // Optional: Rounded corners
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appleSignInButton)
        
        NSLayoutConstraint.activate([
            appleSignInButton.topAnchor.constraint(equalTo: kakaoLoginButton.bottomAnchor, constant: 20),
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.widthAnchor.constraint(equalToConstant: 200),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
