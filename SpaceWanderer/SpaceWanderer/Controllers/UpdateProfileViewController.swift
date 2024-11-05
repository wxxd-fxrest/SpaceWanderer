//
//  UpdateProfileViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/1/24.
//

import UIKit

class UpdateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Nickname"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let birthDayTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Birth Day (YYYY-MM-DD)"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let inhabitedPlanetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Inhabited Planet"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
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
    
    func setupUI() {
        [nicknameTextField, birthDayTextField, inhabitedPlanetTextField, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Set up constraints
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            birthDayTextField.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            birthDayTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            birthDayTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            inhabitedPlanetTextField.topAnchor.constraint(equalTo: birthDayTextField.bottomAnchor, constant: 20),
            inhabitedPlanetTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inhabitedPlanetTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
         
            nextButton.topAnchor.constraint(equalTo: inhabitedPlanetTextField.bottomAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func nextButtonTapped() {
        let nickname = nicknameTextField.text ?? ""
        let birthDay = birthDayTextField.text ?? ""
        let inhabitedPlanet = inhabitedPlanetTextField.text ?? ""
        
        // SelectProfileImageViewController 인스턴스 생성 및 데이터 전달
        let selectProfileVC = SelectProfileImageViewController()
        selectProfileVC.userIdentifier = userIdentifier
        selectProfileVC.nickname = nickname
        selectProfileVC.birthDay = birthDay
        selectProfileVC.inhabitedPlanet = inhabitedPlanet
        
        navigationController?.pushViewController(selectProfileVC, animated: true)
    }
}
