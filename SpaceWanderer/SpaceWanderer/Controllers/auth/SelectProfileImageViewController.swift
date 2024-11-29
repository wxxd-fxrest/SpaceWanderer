//
//  SelectProfileImageViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//

import UIKit

class SelectProfileImageViewController: CustomNavigationController {
    
    var userIdentifier: String?
    var nickname: String?
    var birthDay: String?
    
    private let profileImageView = SelectProfileImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad : ", nickname, birthDay)
        print("viewDidLoad - userIdentifier: ", userIdentifier)

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
        guard let nickname = nickname,
              let birthDay = birthDay else {
            print("Missing user data")
            return
        }
        print("updateProfile : ", nickname, birthDay)
        
        guard let userIdentifier = userIdentifier else { return }
        print("updateProfile : ", userIdentifier)
        
        // APIManager를 사용하여 프로필 업데이트
        UserAPIManager.shared.updateProfile(userIdentifier: userIdentifier, nickname: nickname, birthDay: birthDay, inhabitedPlanet: "수성", profileImage: imageName) { [weak self] result in
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
