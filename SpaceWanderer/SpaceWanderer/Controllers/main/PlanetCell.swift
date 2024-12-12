//
//  PlanetCell.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit

class PlanetCell: UITableViewCell {
    var planetNameLabel: UILabel!
    var planetImageView: UIImageView!
    var requiredStepsLabel: UILabel! // 최소 성공 횟수 라벨 추가

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        planetNameLabel = UILabel()
        planetImageView = UIImageView()
        requiredStepsLabel = UILabel() // 라벨 초기화
        
        contentView.addSubviews(planetNameLabel, planetImageView, requiredStepsLabel)
        
        planetImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView).offset(15)
            $0.centerY.equalTo(contentView)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }

        planetNameLabel.snp.makeConstraints {
            $0.leading.equalTo(planetImageView.snp.trailing).offset(10)
            $0.centerY.equalTo(contentView)
        }

        requiredStepsLabel.snp.makeConstraints {
            $0.trailing.equalTo(contentView).offset(-15)
            $0.centerY.equalTo(contentView)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

