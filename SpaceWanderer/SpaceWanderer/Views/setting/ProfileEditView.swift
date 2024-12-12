//
//  ProfileEditView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit
import Then

class ProfileEditView: UIView {
    
    lazy var nicknameTextFieldLabel = UIFactory.makeLabel(text: "닉네임을 입력해 주세요.", textColor: SpecialColors.WhiteColor.withAlphaComponent(0.8), font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .center)
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none  // 기본 보더 스타일을 제거합니다.
        textField.textColor = SpecialColors.WhiteColor
        textField.tintColor = SpecialColors.MainColor
        textField.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        // 보더 색상 설정
        textField.layer.borderWidth = 2.0  // 보더의 두께
        textField.layer.borderColor = SpecialColors.WhiteColor.withAlphaComponent(0.6).cgColor  // 보더 색상
        textField.layer.cornerRadius = 12
        
        // Placeholder 색상만 설정 (내용은 다른 곳에서 설정)
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: SpecialColors.WhiteColor.withAlphaComponent(0.6) // 원하는 색상 설정
        ]
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "닉네임", attributes: placeholderAttributes)
        
        // 내부 패딩 추가
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // 자동완성 및 단어 추천 비활성화
        textField.autocorrectionType = .no // 자동완성 비활성화
        textField.autocapitalizationType = .none // 자동 대문자 비활성화
        textField.smartDashesType = .no // 스마트 대시 비활성화
        textField.smartQuotesType = .no // 스마트 따옴표 비활성화
        textField.smartInsertDeleteType = .no // 스마트 삽입 및 삭제 비활성화
        textField.spellCheckingType = .no // 맞춤법 검사 비활성화
        
        return textField
    }()
    lazy var nicknameStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [nicknameTextFieldLabel, nicknameTextField],
        axis: .vertical,
        spacing: 14,
        alignment: .leading,
        distribution: .fill
    )
    
    lazy var originButtonLabel = UIFactory.makeLabel(text: "출신 행성을 선택해 주세요.", textColor: SpecialColors.WhiteColor.withAlphaComponent(0.8), font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .left)
    let originButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("선택", for: .normal)
        button.backgroundColor = SpecialColors.WhiteColor
        button.tintColor = SpecialColors.MainViewBackGroundColor
        button.layer.cornerRadius = 12
        return button
    }()
    lazy var originStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [originButtonLabel, originButton],
        axis: .horizontal,
        spacing: 14,
        alignment: .center,
        distribution: .equalSpacing
    )
    
    lazy var profileImageLabel = UIFactory.makeLabel(text: "프로필 이미지를 선택해 주세요.", textColor: SpecialColors.WhiteColor.withAlphaComponent(0.8), font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .left)
    let imageNames = ["profileAlien1", "profileAlien2"]
    private var imageButtons: [UIButton] = []
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.backgroundColor = SpecialColors.MainColor
        button.tintColor = SpecialColors.WhiteColor
        button.layer.cornerRadius = 12
        return button
    }()
    
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
        addSubviews(profileImageLabel, nicknameStackView, originStackView, confirmButton)

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
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(18)  // 화면 상단 20pt 여백
            $0.leading.trailing.equalToSuperview().inset(24)  // 좌우 여백 20
        }
        
        nicknameStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageButtons.last!.snp.bottom).offset(34)
            $0.leading.trailing.equalToSuperview().inset(20)  // 좌우 여백 20
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(nicknameStackView)
            $0.height.equalTo(40)
        }
        
        originStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nicknameStackView.snp.bottom).offset(34)  // 마지막 이미지 버튼의 bottom에 맞추기
            $0.leading.trailing.equalToSuperview().inset(20)  // 좌우 여백 20
        }
        
        originButton.snp.makeConstraints {
            $0.height.equalTo(36)
            $0.width.equalTo(54)
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-34)  // 화면 상단 20pt 여백
            $0.leading.trailing.equalToSuperview().inset(20)  // 좌우 여백 20
            $0.height.equalTo(46)
        }
    }

    private func createImageButton(named imageName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tag = tag
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.borderWidth = 3.0
        button.layer.borderColor = SpecialColors.WhiteColor.withAlphaComponent(0.6).cgColor // 초기 테두리는 없음
        button.layer.cornerRadius = 12.0 // 모서리 둥글게
        button.clipsToBounds = true
        return button
    }
    
    func getImageButtons() -> [UIButton] {
        return imageButtons
    }
}
