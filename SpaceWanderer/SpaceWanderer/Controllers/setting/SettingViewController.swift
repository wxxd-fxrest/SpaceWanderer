//
//  SettingViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/16/24.
//

import UIKit
import KakaoSDKUser

class SettingViewController: CustomNavigationController {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    let kakaoLoginManager = KakaoLoginAPIManager()
    let appleLoginManager = AppleAPILoginManager()
    
    private let settingView = SettingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        // SettingView를 서브뷰로 추가
        view.addSubview(settingView)

        // 버튼 액션 설정
        settingView.logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        settingView.deleteAccountButton.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)

        // SettingView의 frame을 설정
        settingView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(withTitle: "설정", backButtonImage: "LargeLeftIcon")
    }

    @objc private func handleLogout() {
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            switch loginType {
            case "LOGIN_APPLE":
                appleLoginManager.logout()
                print("애플 로그아웃 완료")
                self.navigateToViewVC()
            case "LOGIN_KAKAO":
                kakaoLoginManager.logout { success in
                    if success {
                        print("카카오 로그아웃 완료")
                        self.navigateToViewVC()
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

    @objc private func handleDeleteAccount() {
        guard let userIdentifier = self.userIdentifier else {
            print("사용자 아이디가 없습니다.")
            return
        }
        
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            print("저장된 로그인 타입: \(loginType)")
            
            if loginType == "LOGIN_KAKAO" {
                print("kakao 회원 탈퇴")
                kakaoUnlink()
                self.navigateToViewVC()
            } else if loginType == "LOGIN_APPLE" {
                print("apple 회원 탈퇴")
                appleLoginManager.deleteUserAccount(userIdentifier: userIdentifier, accessToken: self.accessToken) { [weak self] success, message in
                    if success {
                        print("회원 탈퇴 완료")
                        self?.handleLogout()
                        self?.showAlert(message: "회원 탈퇴가 완료되었습니다.")
                        self?.navigateToViewVC()
                    } else {
                        print("회원 탈퇴 실패: \(message)")
                        self?.showAlert(message: "회원 탈퇴에 실패했습니다: \(message)")
                    }
                }
            } else {
                print("알 수 없는 로그인 타입: \(loginType)")
            }
        } else {
            print("저장된 로그인 타입이 없습니다.")
        }
    }
    
    func kakaoUnlink() {
        guard let userIdentifier = UserDefaults.standard.string(forKey: "kakaoUserIdentifier") else {
            print("사용자 식별자(kakaoUserIdentifier)가 UserDefaults에 없습니다.")
            return
        }
        
        kakaoLoginManager.deleteUserDataFromBackend(userIdentifier: userIdentifier) { success in
            if success {
                print("사용자 데이터 삭제 완료.")
                UserDefaults.standard.removeObject(forKey: "kakaoUserIdentifier")
                UserDefaults.standard.removeObject(forKey: "LoginType")
                print("UserDefaults에서 카카오 데이터 삭제 완료.")
                
                UserApi.shared.unlink { error in
                    if let error = error {
                        print("카카오 연결 끊기 실패: \(error)")
                    } else {
                        print("카카오 연결 끊기 성공.")
                    }
                }
            } else {
                print("사용자 데이터 삭제 실패.")
            }
        }
    }

    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func navigateToViewVC() {
        // 네비게이션 스택에서 로그인 화면으로 이동
        if let navigationController = self.navigationController {
            // 로그인 화면으로 전환
            let viewController = ViewController()  // 로그인 화면 클래스 생성
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
