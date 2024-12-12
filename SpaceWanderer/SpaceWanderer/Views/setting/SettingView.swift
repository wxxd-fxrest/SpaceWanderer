//
//  SettingView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit

class SettingView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = SpecialColors.MainViewBackGroundColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        // 구분선 색상 변경
        tableView.separatorColor = SpecialColors.WhiteColor.withAlphaComponent(0.6) // 원하는 색상으로 변경
        tableView.separatorStyle = .singleLine // 구분선 스타일 설정 (기본값: singleLine)
        
        return tableView
    }()
    
    private let menuItems: [String] = ["개인정보 처리방침", "서비스 이용약관", "로그아웃", "회원 탈퇴"]
    
    // 설정 버튼 클릭 시 실행할 함수를 설정하기 위한 클로저
    var handleLogout: (() -> Void)?
    var handleDeleteAccount: (() -> Void)?
    var handleNavigatePersonalInformationVC: (() -> Void)?
    var handleNavigateTermsOfUseViewControllerVC: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(tableView)
        
        // TableView의 레이아웃 설정
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
         }
        
        // TableView의 Delegate와 DataSource 설정
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        
        // 셀의 텍스트 설정
        cell.textLabel?.text = menuItems[indexPath.row]
        
        // 셀 배경색 설정
        cell.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        // 셀 글자색 설정
        cell.textLabel?.textColor = SpecialColors.WhiteColor

        // 셀 선택 시 배경색 설정
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = SpecialColors.MainColor.withAlphaComponent(0.3)
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 클릭 시 각 함수 실행
        switch indexPath.row {
        case 0:
            handleNavigatePersonalInformationVC?()
        case 1:
            handleNavigateTermsOfUseViewControllerVC?()
        case 2:
            handleLogout?()
        case 3:
            handleDeleteAccount?()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true) // 선택된 셀 해제
    }
}
