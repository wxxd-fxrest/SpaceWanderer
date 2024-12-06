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
    }

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
        let nickname = updateProfileView.nicknameTextField.text ?? ""
        let birthDay = viewModel.formatDateToString(updateProfileView.birthDayDatePicker.date)

        // 닉네임 유효성 검사
        guard viewModel.validateNickname(nickname) else {
            showAlert(title: "유효하지 않은 닉네임", message: "닉네임은 3자 이상, 12자 이하이며 특수문자를 포함할 수 없습니다.")
            return
        }

        // APIManager를 사용하여 닉네임 중복 확인
        viewModel.checkNicknameUniqueness(nickname) { [weak self] isUnique in
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
