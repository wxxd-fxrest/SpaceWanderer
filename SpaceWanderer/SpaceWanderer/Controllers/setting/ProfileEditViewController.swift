//
//  ProfileEditViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/16/24.
//

import UIKit

class ProfileEditViewController: CustomNavigationController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var userUniqueId: String?
    var userIdentifier: String?
    
    var previousNickname: String? // 기존 닉네임
    var previousProfileImage: String? // 기존 프로필 이미지
    var selectedImageName: String? // 선택된 이미지
    var previousOrigin: String? // 기존 행성
    var selectedPlanet: String? // 선택된 행성
    
    var selectedImageIndex: Int? // 선택된 이미지 인덱스
    private var imageButtons: [UIButton] = [] // 버튼 참조 배열
    
    private let imageNames = ["spaceProfile1", "spaceProfile2"] // Assets에 있는 이미지 이름

    lazy var backendURL: String = {
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["PROFILE_BASE_URL"] as? String {
            return backendURL
        } else {
            return "http://localhost:1020" // 기본값 설정
        }
    }()
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textColor = SpecialColors.MainViewBackGroundColor
        textField.tintColor = SpecialColors.WhiteColor
        return textField
    }()
    
    private let planets = ["수성", "금성", "지구", "화성", "목성", "토성", "천왕성", "해왕성"]
    
    let originButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("출신 행성 선택", for: .normal)
        button.addTarget(self, action: #selector(selectPlanetTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        setupUI()
        populatePreviousData() // 기존 데이터 초기화
        
        // placeholder를 previousNickname으로 설정
        nicknameTextField.placeholder = previousNickname ?? "닉네임을 입력하세요"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // 인스턴스 메서드로 호출
        setupNavigationBar(withTitle: "프로필 수정", backButtonImage: "LargeLeftIcon")
    }
    
    func setupUI() {
        [nicknameTextField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // 프로필 이미지 버튼 생성
        for (index, imageName) in imageNames.enumerated() {
            let imageButton = createImageButton(named: imageName, tag: index)
            imageButton.frame = CGRect(x: 50 + (150 * index), y: 200, width: 100, height: 100)
            imageButtons.append(imageButton)
            view.addSubview(imageButton)
        }
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.frame = CGRect(x: 125, y: 400, width: 100, height: 50)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        // 출신 행성 버튼 추가
       originButton.translatesAutoresizingMaskIntoConstraints = false
       view.addSubview(originButton)
        
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            originButton.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            originButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createImageButton(named imageName: String, tag: Int) -> UIButton {
         let button = UIButton(type: .custom)
         button.setImage(UIImage(named: imageName), for: .normal)
         button.tag = tag
         button.imageView?.contentMode = .scaleAspectFit
         button.layer.borderWidth = 2.0
         button.layer.borderColor = UIColor.clear.cgColor // 초기 테두리는 없음
         button.layer.cornerRadius = 8.0 // 모서리 둥글게
         button.clipsToBounds = true
         button.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
         return button
    }
    
    @objc private func imageButtonTapped(_ sender: UIButton) {
        // 선택된 이미지 인덱스를 업데이트
          selectedImageIndex = sender.tag
          selectedImageName = imageNames[sender.tag]

          // 모든 버튼 테두리 초기화 후, 선택된 버튼만 테두리 추가
          updateImageBorders()
    }

    private func updateImageBorders() {
        for (index, button) in imageButtons.enumerated() {
            if index == selectedImageIndex {
                button.layer.borderColor = UIColor.red.cgColor // 선택된 이미지에 빨간 테두리
            } else {
                button.layer.borderColor = UIColor.clear.cgColor // 다른 이미지는 테두리 제거
            }
        }
    }
    
    func populatePreviousData() {
        nicknameTextField.placeholder = previousNickname
        selectedImageName = previousProfileImage
        selectedPlanet = previousOrigin
    }
        
    @objc func selectPlanetTapped() {
        // 태양계 행성 리스트 모달 표시
        let alertController = UIAlertController(title: "출신 행성 선택", message: "출신 행성을 선택하세요.", preferredStyle: .actionSheet)
        
        for planet in planets {
            alertController.addAction(UIAlertAction(title: planet, style: .default, handler: { [weak self] _ in
                self?.selectedPlanet = planet
                self?.originButton.setTitle("선택된 행성: \(planet)", for: .normal)
                print("선택된 출신 행성: \(planet)")
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @objc private func confirmButtonTapped() {
        var requestData: [String: Any] = [:]
        
        if let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !nickname.isEmpty,
           nickname != previousNickname {
            // 닉네임 형식 검증
            let nicknamePattern = "^[a-zA-Z가-힣0-9]{3,12}$"
            let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
            
            guard nicknamePredicate.evaluate(with: nickname) else {
                showAlert(title: "유효하지 않은 닉네임", message: "닉네임은 3자 이상, 12자 이하이며 특수문자를 포함할 수 없습니다.")
                return
            }
            
            // 중복 확인 로직 추가
            checkNicknameUniqueness(nickname) { [weak self] isUnique in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if isUnique {
                        // 닉네임 추가
                        requestData["nickname"] = nickname
                        
                        // 다른 필드 확인 및 데이터 추가
                        self.appendOtherUpdateData(to: &requestData)
                        
                        // 요청 데이터 처리
                        self.handleUpdate(requestData: requestData)
                    } else {
                        // 닉네임 중복 경고
                        self.showAlert(title: "닉네임 중복", message: "이미 존재하는 닉네임입니다. 다른 닉네임을 입력해주세요.")
                    }
                }
            }
            return // 중복 확인 결과를 기다리므로 이후 작업 중단
        }

        // 다른 데이터 추가
        appendOtherUpdateData(to: &requestData)

        guard !requestData.isEmpty else {
            // 변경 사항 없음 처리
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }

        // 업데이트 요청 처리
        handleUpdate(requestData: requestData)
    }

    private func appendOtherUpdateData(to requestData: inout [String: Any]) {
        if let selectedImageName = selectedImageName, selectedImageName != previousProfileImage {
            requestData["profileImage"] = selectedImageName
        }
        if let selectedPlanet = selectedPlanet, selectedPlanet != previousOrigin {
            requestData["inhabitedPlanet"] = selectedPlanet
        }
    }

    private func handleUpdate(requestData: [String: Any]) {
        updateProfile(requestData: requestData)
    }

    private func updateProfile(requestData: [String: Any]) {
        guard let userIdentifier = userIdentifier else { return }
        
        guard !requestData.isEmpty, let url = URL(string: "\(backendURL)/profile-update/\(userIdentifier)") else { return }
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
                
                // NotificationCenter를 통해 알림 게시
                NotificationCenter.default.post(name: .planetUpdatedTabBar, object: nil)

                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            task.resume()
        } catch {
            print("Error serializing data: \(error)")
        }
    }
    
    private func checkNicknameUniqueness(_ nickname: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(backendURL)/check-nickname/\(nickname)") else {
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            if let _ = error {
                completion(false)
                return
            }
            
            guard let data = data, let isUnique = try? JSONDecoder().decode(Bool.self, from: data) else {
                completion(false)
                return
            }
            
            completion(isUnique)
        }
        task.resume()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
