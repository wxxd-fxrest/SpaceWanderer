//
//  UpdateProfileView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit
import Then

class UpdateProfileView: UIView {
    lazy var nicknameTextFieldLabel = UIFactory.makeLabel(text: "닉네임을 입력해 주세요.", textColor: SpecialColors.WhiteColor.withAlphaComponent(0.8), font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .center)
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none  // 기본 보더 스타일 제거
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
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "특수문자 제외, 2자 이상 12자 이하", attributes: placeholderAttributes)
        
        // 내부 패딩 추가
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    lazy var nicknameStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [nicknameTextFieldLabel, nicknameTextField],
        axis: .vertical,
        spacing: 14,
        alignment: .leading,
        distribution: .fill
    )

    lazy var birthDayDatePickerLabel = UIFactory.makeLabel(text: "생일을 입력해 주세요.", textColor: SpecialColors.WhiteColor.withAlphaComponent(0.8), font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .left)
    lazy var birthDayAlertLabel = UIFactory.makeLabel(text: "한 번 입력한 생일은 변경할 수 없습니다.", textColor: SpecialColors.AlertRed, font: UIFont.pretendard(style: .regular, size: 14, isScaled: true), textAlignment: .center)
    lazy var birthDayStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [birthDayDatePickerLabel, birthDayAlertLabel],
        axis: .vertical,
        spacing: 12,
        alignment: .leading,
        distribution: .fill
    )
    
    lazy var birthDayPickerView = UIFactory.makeView(backgroundColor: SpecialColors.WhiteColor, cornerRadius: 12)
    let birthDayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        let calendar = Calendar.current
        let tenYearsAgo = calendar.date(byAdding: .year, value: -10, to: Date())!
        datePicker.maximumDate = tenYearsAgo // 10년 전 날짜 설정

        // 한국어 달력 스타일로 변경
        datePicker.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정

        return datePicker
    }()
    lazy var birthDayPickerStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [birthDayStackView, birthDayPickerView],
        axis: .horizontal,
        spacing: 12,
        alignment: .center,
        distribution: .fill
    )

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
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
        addSubviews(nicknameStackView, birthDayPickerStackView, nextButton)
        birthDayPickerView.addSubview(birthDayDatePicker)
        
        nicknameStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(18)  // 화면 상단 20pt 여백
            $0.leading.trailing.equalToSuperview().inset(20)  // 좌우 여백 20
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(nicknameStackView)
            $0.height.equalTo(40)
        }
        
        birthDayPickerStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(24)  // 화면 상단 20pt 여백
            $0.leading.trailing.equalToSuperview().inset(20)  // 좌우 여백 20
        }
        
        birthDayPickerView.snp.makeConstraints {
            $0.height.equalTo(48) // 원하는 높이 설정
            $0.width.equalTo(112) // 원하는 높이 설정
        }
        
        birthDayDatePicker.snp.makeConstraints {
            $0.center.equalToSuperview() // 부모 뷰의 중앙에 위치
        }
    
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-34)  // 화면 상단 20pt 여백
            $0.leading.trailing.equalToSuperview().inset(20)  // 좌우 여백 20
            $0.height.equalTo(46)
        }
    }
}
