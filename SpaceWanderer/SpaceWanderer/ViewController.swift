//
//  ViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/18/24.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController, KakaoAutoLoginManagerDelegate, AppleAutoLoginManagerDelegate {
    let kakaoButton = UIButton(type: .system)
    let appleButton = UIButton(type: .system)

    let kakaoLoginManager = KakaoLoginManager() // KakaoLoginManager 인스턴스 생성
    let appleLoginManager = AppleLoginManager() // AppleLoginManager 인스턴스 생성
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        kakaoLoginManager.autoDelegate = self
        appleLoginManager.autoDelegate = self

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
         

        setupButtons() // 버튼 설정
        // autoLoginIfNeeded() // 자동 로그인 시도
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoLoginIfNeeded() // 여기에서 호출
    }


    // 로그인 버튼을 설정하는 메서드
    private func setupButtons() {
        // 카카오 로그인 버튼
        kakaoButton.setTitle("카카오로 로그인", for: .normal)
        kakaoButton.setTitleColor(.white, for: .normal)
        kakaoButton.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
        
        // 애플 로그인 버튼
        appleButton.setTitle("애플로 로그인", for: .normal)
        appleButton.setTitleColor(.white, for: .normal)
        appleButton.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        
        // 버튼 레이아웃
        let stackView = UIStackView(arrangedSubviews: [kakaoButton, appleButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        // 스택 뷰 추가
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 스택 뷰 제약조건 설정
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    
    // 자동 로그인 처리
    private func autoLoginIfNeeded() {
        // UserDefaults에서 LoginType 읽어오기
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            print("저장된 로그인 타입: \(loginType)")
            
            if loginType == "LOGIN_KAKAO" {
                // Kakao 자동 로그인 시도
                kakaoLoginManager.attemptAutoLogin { accessToken, userUniqueId in
                    if let accessToken = accessToken, let userUniqueId = userUniqueId {
                        print("kakaoLoginManager Access Token: \(accessToken)")
                    } else {
                        print("자동 로그인 실패")
                    }
                }
            } else if loginType == "LOGIN_APPLE" {
                // Apple 자동 로그인 처리
                appleLoginManager.autoLogin { accessToken, userUniqueId in
                    if let accessToken = accessToken, let userUniqueId = userUniqueId {
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
    func didCompleteLogin(userUniqueId: String, userIdentifier: String, accessToken: String) {
        print("이동 전")
        let mainVC = MainViewController()
        mainVC.userUniqueId = userUniqueId // userUniqueId 전달
        mainVC.userIdentifier = userIdentifier // userIdentifier 전달
        mainVC.accessToken = accessToken // accessToken 전달
        navigationController?.pushViewController(mainVC, animated: true)
        print("이동 후")
    }

    // userUniqueId를 화면에 표시하는 메서드
    func displayUserUniqueId(_ userUniqueId: String) {
        // 여기에서 userUniqueId를 표시하는 코드 작성
        print("User Unique ID: \(userUniqueId)")
    }
    
    // 카카오 로그인 버튼 액션
    @objc private func kakaoLoginButtonTapped() {
        // 카카오 로그인 화면으로 이동하는 로직 추가
        let kakaoLoginVC = KakaoLoginViewController() // KakaoLoginViewController를 생성
        navigationController?.pushViewController(kakaoLoginVC, animated: true) // 뷰 컨트롤러 이동
    }
    
    // 애플 로그인 버튼 액션
    @objc private func appleLoginButtonTapped() {
        // 애플 로그인 화면으로 이동하는 로직 추가
        let appleLoginVC = AppleLoginViewController() // AppleLoginViewController를 생성
        navigationController?.pushViewController(appleLoginVC, animated: true) // 뷰 컨트롤러 이동
    }
}
