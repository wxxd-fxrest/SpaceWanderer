//
//  KakaoLoginViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/30/24.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

class KakaoLoginViewController: UIViewController, KakaoLoginManagerDelegate {
    let kakaoLoginManager = KakaoLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kakaoLoginManager.delegate = self

        // UserDefaults에서 저장된 값 출력
        if let kakaoUserIdentifier = UserDefaults.standard.string(forKey: "kakaoUserIdentifier") {
            print("저장된 Kakao 사용자 식별자: \(kakaoUserIdentifier)")
        } else {
            print("저장된 Kakao 사용자 식별자가 없습니다.")
        }
        
        setupKakaoLoginButton()
    }
    
    // Delegate 메서드 구현
    func didRequestReLogin() {
        handleKakaoLogin() // 재로그인 프로세스 시작
    }
    
    private func setupKakaoLoginButton() {
        // 버튼 생성 및 속성 설정
        let kakaoLoginButton = UIButton(type: .system)
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
            kakaoLoginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
                    self.requestAdditionalAgreement()
                    print("Access Token: \(oauthToken.accessToken)")
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
                                let accessToken = oauthToken.accessToken // accessToken도 oauthToken에서 가져옴
                                
                                self.kakaoLoginManager.sendUserInfoToBackend(userIdentifier: "\(userId)", email: email, refreshToken: refreshToken, loginType: loginType, accessToken: accessToken)
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
                    self.requestAdditionalAgreement()
                    print("Access Token: \(oauthToken.accessToken)")
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
                                
                                let accessToken = oauthToken.accessToken // accessToken도 oauthToken에서 가져옴
                                
                                self.kakaoLoginManager.sendUserInfoToBackend(userIdentifier: "\(userId)", email: email, refreshToken: refreshToken, loginType: loginType, accessToken: accessToken)
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

    private func requestAdditionalAgreement() {
        UserApi.shared.accessTokenInfo { (accessTokenInfo, error) in
            if let error = error {
                print("Access Token 오류: \(error)")
            } else if let accessTokenInfo = accessTokenInfo {
                print("Access Token 정보: \(accessTokenInfo)")
            }
        }
    }
    
    // 최초 로그인 후 main 화면으로 뒤로가기
    func didCompleteKakaoLogin() {
        self.navigationController?.popViewController(animated: true) // 뒤로가기
    }
}
