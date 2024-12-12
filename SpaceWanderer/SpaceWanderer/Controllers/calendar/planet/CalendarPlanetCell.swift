//
//  CalendarPlanetCell.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/21/24.
//

import UIKit
import SnapKit

class CalendarPlanetCell: UICollectionViewCell {
    let planetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(planetLabel)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.backgroundColor = SpecialColors.MainViewBackGroundColor

        planetLabel.snp.makeConstraints {
            $0.centerX.equalTo(contentView)
            $0.centerY.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(planet: String) {
        planetLabel.text = planet
    }
}

