//
//  ProfileEditViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/16/24.
//

import UIKit

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    private let imageNames = ["spaceProfile1", "spaceProfile2"] // Assets에 있는 이미지 이름
    private var selectedImageName: String?
    private var previousNickname: String? // 추가된 변수

    lazy var backendURL: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["PROFILE_BASE_URL"] as? String {
            print("PROFILE_BASE_URL", backendURL)
            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Nickname"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let nicknameCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
        button.addTarget(self, action: #selector(nicknameCheckButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // userUniqueId와 accessToken, userIdentifier를 사용하여 필요한 작업 수행
        if let uniqueId = userUniqueId {
            print("받은 userUniqueId: \(uniqueId)")
            // 추가 작업 수행
        }
        if let userIdentifier = userIdentifier {
            print("받은 userIdentifier: \(userIdentifier)")
            // 추가 작업 수행
        }
        if let accessToken = accessToken {
            print("받은 accessToken: \(accessToken)")
            // 추가 작업 수행
        }
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupUI() {
        // TextField와 Button을 뷰에 추가
        [nicknameTextField, nicknameCheckButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // 이미지 버튼 생성
        let imageButton1 = createImageButton(named: imageNames[0], tag: 0)
        imageButton1.frame = CGRect(x: 50, y: 200, width: 100, height: 100)
        view.addSubview(imageButton1)
        
        let imageButton2 = createImageButton(named: imageNames[1], tag: 1)
        imageButton2.frame = CGRect(x: 200, y: 200, width: 100, height: 100)
        view.addSubview(imageButton2)
        
        // 확인 버튼 추가
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.frame = CGRect(x: 125, y: 350, width: 100, height: 50)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        // 버튼이 항상 가장 위에 오도록 설정
        view.bringSubviewToFront(imageButton1)
        view.bringSubviewToFront(imageButton2)
        view.bringSubviewToFront(confirmButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                   
            nicknameCheckButton.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            nicknameCheckButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func nicknameCheckButtonTapped() {
        let nickname = nicknameTextField.text ?? ""

        // nickname 유효성 검사
        let nicknamePattern = "^[a-zA-Z가-힣0-9]{3,12}$" // 영어, 한글, 숫자만 허용
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
        
        guard nicknamePredicate.evaluate(with: nickname) else {
            showAlert(title: "유효하지 않은 닉네임", message: "닉네임은 3자 이상, 12자 이하이며 특수문자를 포함할 수 없습니다.")
            return
        }
        
        // 닉네임 중복 확인
        checkNicknameUniqueness(nickname) { [weak self] isUnique in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if isUnique {
                    self.showAlert(title: "사용 가능 닉네임", message: "사용이 가능한 닉네임입니다.")
                } else {
                    self.showAlert(title: "중복된 닉네임", message: "이미 존재하는 닉네임입니다. 다른 닉네임을 입력해주세요.") {
                        self.nicknameTextField.text = ""
                    }
                }
            }
        }
    }

    // 서버에서 닉네임 중복 확인
    private func checkNicknameUniqueness(_ nickname: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(backendURL)/check-nickname/\(nickname)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error checking nickname uniqueness: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                let responseObject = try JSONDecoder().decode(Bool.self, from: data)
                completion(responseObject)
            } catch {
                print("Error decoding response: \(error)")
                completion(false)
            }
        }
        task.resume()
    }
    
    private func createImageButton(named imageName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tag = tag
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
        
        // 버튼이 상호작용할 수 있도록 설정
        button.isUserInteractionEnabled = true
        return button
    }

    @objc private func imageButtonTapped(_ sender: UIButton) {
        print("Image button tapped with tag: \(sender.tag)")
        selectedImageName = imageNames[sender.tag]
        print("selectedImageName: ", selectedImageName)
    }
    
    // 확인 버튼을 눌렀을 때 호출되는 메서드
    @objc private func confirmButtonTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            showAlert(title: "닉네임 입력", message: "닉네임을 입력해주세요.")
            return
        }
        
        // 닉네임 중복 확인을 아직 하지 않았다면 알림을 표시하고 중복 확인을 하도록 함
        if nickname != previousNickname, !nickname.isEmpty {
            showAlert(title: "닉네임 중복 확인", message: "먼저 닉네임 중복 확인을 해주세요.")
            return
        }
        
        // 이미지만 선택한 경우
        if let selectedImageName = selectedImageName {
            updateProfile(imageName: selectedImageName, nickname: nickname)
        } else {
            // 이미지가 변경되지 않은 경우 닉네임만 업데이트
            updateProfile(nickname: nickname)
        }
    }

    private func updateProfile(imageName: String? = nil, nickname: String) {
        guard let userIdentifier = userIdentifier else { return }
        
        var requestData: [String: Any] = ["nickname": nickname]
        
        // 이미지가 선택되었으면 함께 전달
        if let imageName = imageName {
            requestData["profileImage"] = imageName
        }
        
        // URL 요청 준비
        guard let url = URL(string: "\(backendURL)/profile-update/\(userIdentifier)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error updating profile: \(error)")
                    return
                }
                
                guard let data = data else { return }
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Profile updated: \(responseString)")
                    DispatchQueue.main.async {
                        // 뒤로가기 구현
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            task.resume()
            
        } catch {
            print("Error serializing profile data: \(error)")
        }
    }
    
    // Alert helper method
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    // Date를 "YYYY-MM-DD" 형식으로 변환하는 메서드
    private func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // 경고창 표시 메서드
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true, completion: nil)
    }
}
