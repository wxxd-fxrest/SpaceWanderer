//
//  UpdateProfileViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/1/24.
//

import UIKit

class UpdateProfileViewController: CustomNavigationController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let viewModel = UpdateProfileViewModel()
    private let updateProfileView = UpdateProfileView()
    
    var userUniqueId: String? {
        didSet {
            viewModel.userUniqueId = userUniqueId
        }
    }
    
    var userIdentifier: String? {
        didSet {
            viewModel.userIdentifier = userIdentifier
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        setupUI()

        // 버튼 액션 설정
        updateProfileView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        // Keyboard Setup
        setupKeyboardHandling()
        setupTapGesture()
        
        // Return 키를 Next로 설정
        updateProfileView.nicknameTextField.returnKeyType = .next
        updateProfileView.nicknameTextField.delegate = self
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

    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(withTitle: "프로필 생성", backButtonImage: "")
        self.navigationItem.leftBarButtonItem = nil // 뒤로가기 버튼 제거
    }

    private func setupUI() {
        view.addSubview(updateProfileView)
        updateProfileView.frame = view.bounds // Fill the view
    }

    @objc func nextButtonTapped() {
        dismissKeyboard()
        
        let nickname = updateProfileView.nicknameTextField.text ?? ""
        let birthDay = viewModel.formatDateToString(updateProfileView.birthDayDatePicker.date)

        // 닉네임 유효성 검사
        guard viewModel.validateNickname(nickname) else {
            showAlert(title: "유효하지 않은 닉네임", message: "닉네임은 3자 이상, 12자 이하이며 특수문자를 포함할 수 없습니다.")
            return
        }

        // 닉네임과 생일을 확인하는 알림창 표시
        let confirmationAlert = UIAlertController(
            title: "프로필 정보 확인",
            message: "닉네임: \(nickname)\n생일: \(birthDay)\n이 정보가 맞나요?",
            preferredStyle: .alert
        )

        // 확인 버튼
        confirmationAlert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // APIManager를 사용하여 닉네임 중복 확인
            self.viewModel.checkNicknameUniqueness(nickname) { [weak self] isUnique in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    if isUnique {
                        // SelectProfileImageViewController 인스턴스 생성 및 데이터 전달
                        let selectProfileVC = SelectProfileImageViewController()
                        selectProfileVC.configure(with: self.viewModel.userIdentifier, nickname: nickname, birthDay: birthDay)
                        
                        self.navigationController?.pushViewController(selectProfileVC, animated: true)
                    } else {
                        self.showAlert(title: "중복된 닉네임", message: "이미 존재하는 닉네임입니다. 다른 닉네임을 입력해주세요.") {
                            self.updateProfileView.nicknameTextField.text = ""
                        }
                    }
                }
            }
        })

        // 취소 버튼
        confirmationAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        // 알림창 표시
        present(confirmationAlert, animated: true, completion: nil)
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

extension UpdateProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == updateProfileView.nicknameTextField {
            // 닉네임 입력 후 Next 버튼 클릭 시 selectPlanetTapped 실행
            nextButtonTapped()
            return false // 키보드 내려가기
        }
        return true
    }
}
