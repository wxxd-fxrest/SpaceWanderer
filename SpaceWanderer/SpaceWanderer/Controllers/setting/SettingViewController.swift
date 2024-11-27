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
    
    let kakaoLoginManager = KakaoLoginManager() // KakaoLoginManager 인스턴스 생성
    let appleLoginManager = AppleLoginManager() // AppleLoginManager 인스턴스 생성
    
    private let loginView = LoginView()

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        setupLogoutButton() // 로그아웃 버튼 설정
        setupDeleteAccountButton() // 회원 탈퇴 버튼 설정
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(withTitle: "설정", backButtonImage: "LargeLeftIcon")
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
            logoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupDeleteAccountButton() {
        // 회원 탈퇴 버튼 생성 및 속성 설정
        let deleteAccountButton = UIButton(type: .system)
        deleteAccountButton.setTitle("회원 탈퇴", for: .normal)
        deleteAccountButton.setTitleColor(.red, for: .normal)
        deleteAccountButton.layer.cornerRadius = 8
        deleteAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        deleteAccountButton.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
        
        // 버튼 레이아웃 설정
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteAccountButton)
        
        // 버튼 위치 제약 설정 (로그아웃 버튼 위)
        NSLayoutConstraint.activate([
            deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteAccountButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            deleteAccountButton.widthAnchor.constraint(equalToConstant: 200),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func handleLogout() {
        // UserDefaults에서 로그인 타입 확인
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            switch loginType {
            case "LOGIN_APPLE":
                appleLoginManager.logout()
                print("애플 로그아웃 완료")
                
                // 애플 로그아웃 후 로그인 화면으로 이동
                self.navigateToViewVC()
                // 로그인 버튼 보이기
                self.loginView.showLoginButtons()
            case "LOGIN_KAKAO":
                kakaoLoginManager.logout { success in
                    if success {
                        print("카카오 로그아웃 완료")
                        
                        // 로그아웃 성공 후 화면 전환
                        self.navigateToViewVC()
                        // 로그인 버튼 보이기
                        self.loginView.showLoginButtons()
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
        
        // UserDefaults에서 LoginType 읽어오기
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            print("저장된 로그인 타입: \(loginType)")
            
            if loginType == "LOGIN_KAKAO" {
                print("kakao 회원 탈퇴")
                kakaoUnlink()
                
                // 회원 탈퇴 후 로그인 화면으로 이동
                self.navigateToViewVC()
            } else if loginType == "LOGIN_APPLE" {
                print("apple 회원 탈퇴")
                deleteUserAccount(userIdentifier: userIdentifier) { success, message in
                    if success {
                        print("회원 탈퇴 완료")
                        // 탈퇴 후 로그아웃 처리 및 UI 업데이트
                        self.handleLogout()
                        self.showAlert(message: "회원 탈퇴가 완료되었습니다.")
                        
                        // 회원 탈퇴 후 로그인 화면으로 이동
                        self.navigateToViewVC()
                    } else {
                        print("회원 탈퇴 실패: \(message)")
                        self.showAlert(message: "회원 탈퇴에 실패했습니다: \(message)")
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
        // 1. 사용자 데이터 삭제: 백엔드 API를 통해 사용자 데이터 삭제 요청
        guard let userIdentifier = UserDefaults.standard.string(forKey: "kakaoUserIdentifier") else {
            print("사용자 식별자(kakaoUserIdentifier)가 UserDefaults에 없습니다.")
            return
        }
        
        // 사용자 데이터를 백엔드에서 삭제
        kakaoLoginManager.deleteUserDataFromBackend(userIdentifier: userIdentifier) { success in
            if success {
                print("사용자 데이터 삭제 완료.")
                
                // 2. UserDefaults에서 카카오 관련 데이터 삭제
                UserDefaults.standard.removeObject(forKey: "kakaoUserIdentifier")
                UserDefaults.standard.removeObject(forKey: "LoginType")
                print("UserDefaults에서 카카오 데이터 삭제 완료.")
                
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
                
                // 3. 카카오 연결 끊기
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
    
    private func deleteUserAccount(userIdentifier: String, completion: @escaping (Bool, String) -> Void) {
        print("deleteUserAccount userIdentifier: ", userIdentifier)
        // 서버에 DELETE 요청 보내기
        let url = URL(string: "\(backendURL)/apple-delete/\(userIdentifier)")!
        var request = URLRequest(url: url)
        print("deleteUserAccount url: ", url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.accessToken ?? "")", forHTTPHeaderField: "Authorization") // 토큰이 있다면 헤더에 추가
        
        let body: [String: Any] = ["userIdentifier": userIdentifier]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, "서버와의 연결에 실패했습니다: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, "서버 응답을 받지 못했습니다.")
                }
                return
            }
            
            // 서버 응답 디버깅
            if let responseString = String(data: data, encoding: .utf8) {
                print("서버 응답: \(responseString)")  // 응답 내용 출력
            }
            
            // 응답 처리
            if let responseString = String(data: data, encoding: .utf8), responseString.contains("회원 탈퇴가 완료되었습니다.") {
                // 2. UserDefaults에서 관련 데이터 삭제
                 UserDefaults.standard.removeObject(forKey: "appleUserIdentifier")
                 UserDefaults.standard.removeObject(forKey: "LoginType")
                 print("UserDefaults에서 애플 데이터 삭제 완료.")
        
                DispatchQueue.main.async {
                    completion(true, responseString)
                }
            } else {
                // 응답 내용이 예상과 다를 경우 좀 더 구체적인 오류 처리
                let errorMessage = "서버에서 예상치 못한 응답을 받았습니다: \(String(data: data, encoding: .utf8) ?? "알 수 없는 오류")"
                DispatchQueue.main.async {
                    completion(false, errorMessage)
                }
            }
        }
        
        task.resume()
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

