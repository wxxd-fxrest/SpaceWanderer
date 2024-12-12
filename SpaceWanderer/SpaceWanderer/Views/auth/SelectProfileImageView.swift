//
//  SelectProfileImageView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit

class SelectProfileImageView: UIView {
    lazy var profileImageLabel = UIFactory.makeLabel(
        text: "프로필 이미지를 선택해 주세요.",
        textColor: SpecialColors.WhiteColor.withAlphaComponent(0.8),
        font: UIFont.pretendard(style: .regular, size: 16, isScaled: true),
        textAlignment: .left
    )

    private let imageNames = ["profileAlien1", "profileAlien2"] // Assets에 있는 이미지 이름
    private var selectedImageIndex: Int? // 선택된 이미지의 인덱스
    private var imageButtons: [UIButton] = [] // 버튼 배열
    var selectedImageName: String? // 선택된 이미지
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("프로필 생성 완료", for: .normal)
        button.backgroundColor = SpecialColors.MainColor
        button.tintColor = SpecialColors.WhiteColor
        button.layer.cornerRadius = 12
        return button
    }()

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
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)

        addSubviews(profileImageLabel, confirmButton)

        // 디바이스 화면 크기와 여백을 고려한 계산
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 24
        let buttonWidth = (screenWidth - (padding * 2) - CGFloat(imageNames.count - 1) * 10) / CGFloat(imageNames.count)
        let buttonHeight = buttonWidth // 정사각형

        // 이미지 버튼 추가
        for (index, imageName) in imageNames.enumerated() {
            let imageButton = createImageButton(named: imageName, tag: index)
            
            // 버튼의 내 패딩을 설정 (10pt)
            imageButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
            
            addSubview(imageButton)
            
            // 이미지 버튼을 화면 맨 위에 배치
            imageButton.snp.makeConstraints {
                $0.top.equalTo(profileImageLabel.snp.bottom).offset(14)  // 화면 상단 14pt 여백
                $0.width.equalTo(buttonWidth)
                $0.height.equalTo(buttonHeight)
                $0.left.equalToSuperview().offset(padding + (buttonWidth + 20) * CGFloat(index))
            }
            
            imageButtons.append(imageButton)
        }

        profileImageLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(18)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-34)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(46)
        }
    }

    private func createImageButton(named imageName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tag = tag
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.borderWidth = 3.0
        button.layer.borderColor = SpecialColors.WhiteColor.withAlphaComponent(0.3).cgColor // 기본 테두리 색상
        button.layer.cornerRadius = 12.0
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside) // 버튼 클릭 이벤트 추가
        return button
    }

    @objc private func imageButtonTapped(_ sender: UIButton) {
        // 선택된 버튼의 태그를 인덱스로 설정
        selectedImageIndex = sender.tag
        selectedImageName = imageNames[sender.tag]
        print("Image selected: \(selectedImageName ?? "없음")")

        // 버튼 테두리 색상 업데이트
        updateImageBorders()
    }

    private func updateImageBorders() {
        for (index, button) in imageButtons.enumerated() {
            if index == selectedImageIndex {
                button.layer.borderColor = SpecialColors.MainColor.cgColor // 선택된 버튼 테두리
            } else {
                button.layer.borderColor = SpecialColors.WhiteColor.withAlphaComponent(0.3).cgColor // 기본 테두리
            }
        }
    }

    @objc private func confirmButtonTapped() {
        guard let selectedImageName = selectedImageName else {
            print("이미지를 선택해주세요.")
            return
        }
        onImageSelected?(selectedImageName)
    }
}
