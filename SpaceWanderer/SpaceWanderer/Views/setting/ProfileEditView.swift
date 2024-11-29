//
//  ProfileEditView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class ProfileEditView: UIView {
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textColor = SpecialColors.MainViewBackGroundColor
        textField.tintColor = SpecialColors.WhiteColor
        return textField
    }()
    
    let originButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("출신 행성 선택", for: .normal)
        return button
    }()
    
    let imageNames = ["spaceProfile1", "spaceProfile2"]
    private var imageButtons: [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = SpecialColors.MainViewBackGroundColor

        // Add nickname text field
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nicknameTextField)

        // Add image buttons
        for (index, imageName) in imageNames.enumerated() {
            let imageButton = createImageButton(named: imageName, tag: index)
            imageButton.frame = CGRect(x: 50 + (150 * index), y: 200, width: 100, height: 100)
            imageButtons.append(imageButton)
            addSubview(imageButton)
        }

        // Add origin button
        originButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(originButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            originButton.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            originButton.centerXAnchor.constraint(equalTo: centerXAnchor)
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
        return button
    }
    
    func getImageButtons() -> [UIButton] {
        return imageButtons
    }
}
