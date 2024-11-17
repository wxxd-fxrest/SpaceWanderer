//
//  CalendarDayCell.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/15/24.
//

import UIKit

class CalendarDayCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let statusIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(statusIndicator)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 10),
            statusIndicator.heightAnchor.constraint(equalToConstant: 10),
            statusIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            statusIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        statusIndicator.layer.cornerRadius = 5
    }
    
    func configure(date: Date, steps: Int) {
        let day = Calendar.current.component(.day, from: date)
        dayLabel.text = "\(day)"
        
        // 오늘 날짜 구하기
        let today = Date()
        let calendar = Calendar.current
        
        // 오늘 이후 날짜인지 확인
         let isFutureDate = date > today
         
         // 오늘 날짜까지는 statusIndicator를 표시하고, 오늘 이후 날짜는 숨기기
         if isFutureDate {
             statusIndicator.isHidden = true
             isUserInteractionEnabled = false
         } else {
             statusIndicator.isHidden = false
             isUserInteractionEnabled = true
         }
        
        // 10,000보 이상일 때 초록색, 아닐 때 빨간색으로 표시
        statusIndicator.backgroundColor = steps >= 10000 ? .green : .red
        
        // 글자 색 변경: 10,000보 이상일 때 초록색, 그 외에는 회색으로 설정
        dayLabel.textColor = steps >= 10000 ? SpecialColors.WhiteColor : SpecialColors.GearGray
    }
}
