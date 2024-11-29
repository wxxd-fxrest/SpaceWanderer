//
//  CustomNavigationController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/17/24.
//

import UIKit

class CustomNavigationController: UIViewController {
    func setupNavigationBar(withTitle title: String, backButtonImage: String) {
        // 뒤로가기 버튼 색상 설정
        self.navigationController?.navigationBar.tintColor = SpecialColors.WhiteColor // 원하는 색상으로 변경

        // 네비게이션 타이틀 설정
        self.navigationController?.navigationBar.topItem?.title = title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: SpecialColors.WhiteColor]

        // 기본 뒤로가기 버튼 숨기기
        self.navigationItem.hidesBackButton = true
        
        // 커스텀 뒤로가기 버튼 설정
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: backButtonImage), for: .normal) // 원하는 아이콘 설정
        backButton.tintColor = SpecialColors.WhiteColor // 원하는 색상으로 변경
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40) // 버튼 크기 설정
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
