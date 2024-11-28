//
//  PlanetCell.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class PlanetCell: UITableViewCell {
    var planetNameLabel: UILabel!
    var planetImageView: UIImageView!
    var requiredStepsLabel: UILabel! // 최소 성공 횟수 라벨 추가

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        planetNameLabel = UILabel()
        planetImageView = UIImageView()
        requiredStepsLabel = UILabel() // 라벨 초기화
        
        // 셀 내부 UI 구성
        planetNameLabel.translatesAutoresizingMaskIntoConstraints = false
        planetImageView.translatesAutoresizingMaskIntoConstraints = false
        requiredStepsLabel.translatesAutoresizingMaskIntoConstraints = false // 라벨 제약 설정
        
        contentView.addSubview(planetNameLabel)
        contentView.addSubview(planetImageView)
        contentView.addSubview(requiredStepsLabel) // 라벨 추가
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            planetImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            planetImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            planetImageView.widthAnchor.constraint(equalToConstant: 24),
            planetImageView.heightAnchor.constraint(equalToConstant: 24),
            
            planetNameLabel.leadingAnchor.constraint(equalTo: planetImageView.trailingAnchor, constant: 10),
            planetNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            requiredStepsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15), // 오른쪽 여백
            requiredStepsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor) // 세로 중앙 정렬
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

