//
//  SettingView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class SettingView: UIView {
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원 탈퇴", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
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
        
        // 버튼 레이아웃 설정
        addSubview(logoutButton)
        addSubview(deleteAccountButton)
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),

            deleteAccountButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            deleteAccountButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20),
            deleteAccountButton.widthAnchor.constraint(equalToConstant: 200),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
