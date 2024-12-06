//
//  SelectProfileImageViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//

import UIKit

class SelectProfileImageViewController: CustomNavigationController {
    
    private let viewModel = SelectProfileImageViewModel()
    private let profileImageView = SelectProfileImageView()

    // ViewModel에 사용자 정보를 설정하는 메서드
    func configure(with userIdentifier: String?, nickname: String?, birthDay: String?) {
        viewModel.userIdentifier = userIdentifier
        viewModel.nickname = nickname
        viewModel.birthDay = birthDay
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        print("viewDidLoad : ", viewModel.nickname ?? "", viewModel.birthDay ?? "")
        print("viewDidLoad - userIdentifier: ", viewModel.userIdentifier ?? "")

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(withTitle: "프로필 생성", backButtonImage: "LargeLeftIcon")
    }

    private func setupUI() {
        view.addSubview(profileImageView)
        profileImageView.frame = view.bounds // Fill the view

        // 이미지 선택 이벤트 처리
        profileImageView.onImageSelected = { [weak self] selectedImageName in
            self?.updateProfile(imageName: selectedImageName)
        }
    }

    private func updateProfile(imageName: String) {
        viewModel.updateProfile(imageName: imageName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigateToViewController()
                case .failure(let error):
                    self?.showAlert(title: "오류", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func navigateToViewController() {
        let viewController = ViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Alert helper method
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
