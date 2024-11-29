//
//  UpdateProfileView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class UpdateProfileView: UIView {
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Nickname"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let birthDayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        let calendar = Calendar.current
        let tenYearsAgo = calendar.date(byAdding: .year, value: -10, to: Date())!
        datePicker.maximumDate = tenYearsAgo // 10년 전 날짜 설정
        return datePicker
    }()

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
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
        [nicknameTextField, birthDayDatePicker, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        // Set up constraints
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            birthDayDatePicker.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            birthDayDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            birthDayDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            nextButton.topAnchor.constraint(equalTo: birthDayDatePicker.bottomAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
