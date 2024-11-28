//
//  DestinationSelectionView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class DestinationSelectionView: UIView {
    var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.backgroundColor = SpecialColors.MainViewBackGroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // 테이블 뷰 구체적인 설정
        addSubview(tableView)
        
        // 테이블 뷰 레이아웃 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
