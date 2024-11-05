//
//  MainViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//

import UIKit

class MainViewController: UIViewController {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    let kakaoLoginManager = KakaoLoginManager() // KakaoLoginManager 인스턴스 생성
    let appleLoginManager = AppleLoginManager() // AppleLoginManager 인스턴스 생성

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        setupLogoutButton() // 로그아웃 버튼 설정
    }
    
    private func setupLogoutButton() {
        // 로그아웃 버튼 생성 및 속성 설정
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.layer.cornerRadius = 8
        logoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        // 버튼 레이아웃 설정
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        // 버튼 위치 제약 설정 (카카오 로그인 버튼 아래)
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func handleLogout() {
        // UserDefaults에서 로그인 타입 확인
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            switch loginType {
            case "LOGIN_APPLE":
                appleLoginManager.logout()
                print("애플 로그아웃 완료")
                // 애플 로그아웃 후 UI 업데이트 등 필요한 추가 작업 수행

            case "LOGIN_KAKAO":
                kakaoLoginManager.logout { success in
                    if success {
                        print("카카오 로그아웃 완료")
                        // 카카오 로그아웃 후 UI 업데이트 등 필요한 추가 작업 수행
                    } else {
                        print("카카오 로그아웃 실패")
                    }
                }

            default:
                print("알 수 없는 로그인 타입입니다.")
            }
        } else {
            print("로그인 타입이 UserDefaults에 저장되어 있지 않습니다.")
        }
    }
}
