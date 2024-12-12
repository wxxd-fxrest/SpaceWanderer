//
//  ProfileEditViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/16/24.
//

import UIKit

class ProfileEditViewController: CustomNavigationController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    var userUniqueId: String?
    var userIdentifier: String?
    
    var previousNickname: String? // 기존 닉네임
    var previousProfileImage: String? // 기존 프로필 이미지
    var selectedImageName: String? // 선택된 이미지
    var previousOrigin: String? // 기존 행성
    var selectedPlanet: String? // 선택된 행성
    var selectedImageIndex: Int? // 선택된 이미지 인덱스
    
    private let profileEditView = ProfileEditView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(profileEditView)
        profileEditView.frame = view.bounds // Fill the view
        profileEditView.nicknameTextField.placeholder = previousNickname ?? "닉네임을 입력하세요"
        
        setupNavigationBar(withTitle: "프로필 수정", backButtonImage: "LargeLeftIcon")
        
        // Add target actions
        profileEditView.originButton.addTarget(self, action: #selector(selectPlanetTapped), for: .touchUpInside)
        
        // Set up image button actions
        let imageButtons = profileEditView.getImageButtons()
        for button in imageButtons {
            button.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
        }
        
        // confirmButton에 target 액션 추가
        profileEditView.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        // Keyboard Setup
        setupKeyboardHandling()
        setupTapGesture()
        
        // Return 키를 '완료'로 설정
        profileEditView.nicknameTextField.returnKeyType = .done
        profileEditView.nicknameTextField.delegate = self
    }
    
    // MARK: Keyboard handling
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == profileEditView.nicknameTextField {
            // '완료' 버튼을 클릭하면 키보드 내려가기
            textField.resignFirstResponder() // 키보드 내려가기
            return false // 텍스트 필드에서 포커스 해제
        }
        return true
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // 인스턴스 메서드로 호출
        setupNavigationBar(withTitle: "프로필 수정", backButtonImage: "LargeLeftIcon")
    }
    
    // MARK: imageButtonTapped
    @objc private func imageButtonTapped(_ sender: UIButton) {
        // 선택된 이미지 인덱스를 업데이트
        selectedImageIndex = sender.tag
        selectedImageName = profileEditView.imageNames[sender.tag]
        
        // 모든 버튼 테두리 초기화 후, 선택된 버튼만 테두리 추가
        updateImageBorders()
    }
    
    private func updateImageBorders() {
        let imageButtons = profileEditView.getImageButtons()
        for (index, button) in imageButtons.enumerated() {
            if index == selectedImageIndex {
                button.layer.borderColor = SpecialColors.MainColor.cgColor // 선택된 이미지에 빨간 테두리
            } else {
                button.layer.borderColor = SpecialColors.WhiteColor.withAlphaComponent(0.3).cgColor // 다른 이미지는 테두리 제거
            }
        }
    }
    
    @objc func selectPlanetTapped() {
        // 태양계 행성 리스트 모달 표시
        let alertController = UIAlertController(title: "출신 행성 선택", message: "출신 행성을 선택하세요.", preferredStyle: .actionSheet)
        
        // APIManager를 사용하여 행성 데이터 가져오기
        PlanetAPIManager.shared.fetchPlanets { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let planets):
                    for planet in planets {
                        alertController.addAction(UIAlertAction(title: planet.name, style: .default, handler: { [weak self] _ in
                            self?.selectedPlanet = planet.name
                            self?.profileEditView.originButton.setTitle("\(planet.name)", for: .normal)
                            print("선택된 출신 행성: \(planet.name)")
                        }))
                    }
                    
                    alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                    self?.present(alertController, animated: true, completion: nil)
                    
                case .failure(let error):
                    self?.showAlert(title: "에러", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func confirmButtonTapped() {
        var requestData: [String: Any] = [:]
        
        if let nickname = profileEditView.nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !nickname.isEmpty,
           nickname != previousNickname {
            // 닉네임 형식 검증
            let nicknamePattern = "^[a-zA-Z가-힣0-9]{2,12}$"
            let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
            
            guard nicknamePredicate.evaluate(with: nickname) else {
                showAlert(title: "유효하지 않은 닉네임", message: "닉네임은 3자 이상, 12자 이하이며 특수문자를 포함할 수 없습니다.")
                return
            }
            
            // APIManager를 사용하여 닉네임 유니크 체크
            UserAPIManager.shared.checkNicknameUniqueness(nickname) { [weak self] isUnique in
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
        guard let userIdentifier = userIdentifier else { return }
        
        UserAPIManager.shared.updateProfile(userIdentifier: userIdentifier, requestData: requestData) { [weak self] result in
            switch result {
            case .success:
                // NotificationCenter를 통해 알림 게시
                NotificationCenter.default.post(name: .planetUpdatedTabBar, object: nil)
                
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                print("Error updating profile: \(error)")
                // 필요 시 에러 핸들링 추가
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
