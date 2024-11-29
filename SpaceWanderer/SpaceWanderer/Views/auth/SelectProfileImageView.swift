//
//  SelectProfileImageView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class SelectProfileImageView: UIView {
    
    private let imageNames = ["spaceProfile1", "spaceProfile2"] // Assets에 있는 이미지 이름
    private var selectedImageName: String?
    
    // 프로필 이미지 선택 이벤트를 처리할 클로저
    var onImageSelected: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .white

        let imageButton1 = createImageButton(named: imageNames[0], tag: 0)
        imageButton1.frame = CGRect(x: 50, y: 100, width: 100, height: 100)
        addSubview(imageButton1)
        
        let imageButton2 = createImageButton(named: imageNames[1], tag: 1)
        imageButton2.frame = CGRect(x: 200, y: 100, width: 100, height: 100)
        addSubview(imageButton2)
        
        // 확인 버튼 추가
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.frame = CGRect(x: 125, y: 250, width: 100, height: 50)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        addSubview(confirmButton)
    }

    private func createImageButton(named imageName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tag = tag
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func imageButtonTapped(_ sender: UIButton) {
        print("Image button tapped with tag: \(sender.tag)")
        selectedImageName = imageNames[sender.tag]
        print("selectedImageName: ", selectedImageName)
    }
    
    @objc private func confirmButtonTapped() {
        guard let selectedImageName = selectedImageName else {
            // 이미지가 선택되지 않았을 때의 처리
            print("이미지를 선택해주세요.")
            return
        }
        // 이미지가 선택되었을 때, 클로저를 통해 상위 뷰 컨트롤러에 알림
        onImageSelected?(selectedImageName)
    }
}
