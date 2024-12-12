//
//  CalendarDayCell.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/15/24.
//

import UIKit
import SnapKit

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
        
        dayLabel.snp.makeConstraints {
            $0.center.equalToSuperview() // dayLabel을 contentView의 중앙에 배치
        }
        
        statusIndicator.snp.makeConstraints {
            $0.width.height.equalTo(10) // statusIndicator의 가로, 세로 크기를 10으로 설정
            $0.centerX.equalToSuperview() // contentView의 중심에 X축 정렬
            $0.bottom.equalToSuperview().inset(4) // contentView의 아래쪽에서 4만큼 떨어지도록 설정
        }
        
        statusIndicator.layer.cornerRadius = 5 // 원형으로 만들기 위해 cornerRadius 설정
    }

    func configure(date: Date, steps: Int) {
        let day = Calendar.current.component(.day, from: date)
        dayLabel.text = "\(day)"
        
        // 오늘 날짜 구하기
        let today = Date()
        let calendar = Calendar.current
        
        // 오늘 이후 날짜인지 확인
        let isFutureDate = date > today
        
        // 걸음 수가 0일 경우 처리
        if steps == 0 {
            statusIndicator.isHidden = true // 상태 인디케이터 숨김
            isUserInteractionEnabled = false // 클릭 불가
            dayLabel.textColor = SpecialColors.GearGray // 날짜 색상 변경 (예: 회색)
        } else {
            // 오늘 날짜까지는 statusIndicator를 표시하고, 오늘 이후 날짜는 숨기기
            if isFutureDate {
                statusIndicator.isHidden = true
                isUserInteractionEnabled = false
            } else {
                statusIndicator.isHidden = false
                isUserInteractionEnabled = true
            }

            // 10,000보 이상일 때 초록색, 아닐 때 빨간색으로 표시
            statusIndicator.layer.borderWidth = 0.9
            statusIndicator.layer.borderColor = steps >= 10000 ? SpecialColors.MainColor.cgColor : SpecialColors.AlertRed.cgColor
            statusIndicator.backgroundColor = steps >= 10000 ? SpecialColors.MainColor : SpecialColors.MainViewBackGroundColor
            
            // 글자 색 변경: 10,000보 이상일 때 초록색, 그 외에는 기본 색상으로 설정
            dayLabel.textColor = steps >= 10000 ? SpecialColors.WhiteColor : SpecialColors.GearGray
        }
    }
}
