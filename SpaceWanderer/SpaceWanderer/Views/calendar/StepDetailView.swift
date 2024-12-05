//
//  StepDetailView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit
import Then

class StepDetailView: UIView {
    // MARK: - UI Elements
    lazy var cardView = UIFactory.makeView(backgroundColor: SpecialColors.WhiteColor, cornerRadius: 12)
    
    // Header
    lazy var systemIconImage = UIFactory.makeImageView(imageName: "BlackSettingsIcon")
    lazy var systemTitleLabel = UIFactory.makeLabel(text: "SYSTEM", textColor: SpecialColors.MainViewBackGroundColor, font: UIFont.pretendard(style: .bold, size: 18, isScaled: true), textAlignment: .center)
    lazy var systemStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [systemIconImage, systemTitleLabel],
        axis: .horizontal,
        spacing: 12,
        alignment: .leading,
        distribution: .fill
    )
    lazy var cardLine = UIFactory.makeView(backgroundColor: SpecialColors.MainViewBackGroundColor.withAlphaComponent(0.2))
    
    // Image
    lazy var imageBackView = UIFactory.makeView(backgroundColor: SpecialColors.MainViewBackGroundColor.withAlphaComponent(0.2), cornerRadius: 12)
    lazy var imageInnerBackView = UIFactory.makeView(backgroundColor: SpecialColors.MainViewBackGroundColor, cornerRadius: 8)
    let imageView = UIImageView() // 이미지 뷰 추가

    // Info
    lazy var destinationLabel = UIFactory.makeLabel(text: "destination", textColor: SpecialColors.MainViewBackGroundColor, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .center)
    lazy var dateLabel = UIFactory.makeLabel(text: "date", textColor: SpecialColors.MainViewBackGroundColor, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .center)
    lazy var stepsLabel = UIFactory.makeLabel(text: "step", textColor: SpecialColors.MainViewBackGroundColor, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .center)
    lazy var resultLabel = UIFactory.makeLabel(text: "destination", textColor: SpecialColors.MainViewBackGroundColor, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .center)
    lazy var infoStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [destinationLabel, dateLabel, stepsLabel, resultLabel],
        axis: .vertical,
        spacing: 12,
        alignment: .leading,
        distribution: .fill
    )
    
    lazy var middleStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [imageBackView, infoStackView],
        axis: .horizontal,
        spacing: 12,
        alignment: .center,
        distribution: .equalCentering
    )
    
    // goGuestBookButton은 나중에 개발
    var goGuestBookButton = UIFactory.makeLoginButton(
        title: "방명록",
        titleColor: SpecialColors.MainViewBackGroundColor,
        font: UIFont.systemFont(ofSize: 16),
        backgroundColor: SpecialColors.MainViewBackGroundColor.withAlphaComponent(0.8),
        cornerRadius: 12,
        imagePadding: 10
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // UI 요소 추가
        addSubview(cardView)
        cardView.addSubviews(systemStackView, cardLine, middleStackView) // systemStackView를 cardView에 추가
        imageBackView.addSubview(imageInnerBackView)
        imageInnerBackView.addSubview(imageView)
        
        cardView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        systemStackView.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.top).offset(14) // 원하는 상단 간격
            $0.leading.equalTo(cardView.snp.leading).offset(16) // 왼쪽 여백
            $0.trailing.lessThanOrEqualTo(cardView.snp.trailing).inset(16) // 오른쪽 간격 제한 (필요 시)
        }
        
        systemIconImage.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        cardLine.snp.makeConstraints {
            $0.centerX.equalTo(cardView) // cardView를 기준으로 centerX 설정
            $0.top.equalTo(systemStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(cardView)
            $0.height.equalTo(1)
        }
        
        middleStackView.snp.makeConstraints {
            $0.centerX.equalTo(cardView)
            $0.top.equalTo(cardLine.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(cardView).inset(20)
            $0.bottom.equalTo(cardView.snp.bottom).offset(-22) // cardView의 bottom과 연결
        }
        
        imageBackView.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.height.equalTo(120)
        }
        
        imageInnerBackView.snp.makeConstraints {
            $0.center.equalTo(imageBackView) // imageBackView의 중앙에 배치
            $0.edges.equalToSuperview().inset(4) // imageBackView 내부 여백 설정
        }
        
        imageView.snp.makeConstraints {
            $0.center.equalTo(imageInnerBackView) // imageBackView의 중앙에 배치
            $0.edges.equalToSuperview().inset(12) // imageBackView 내부 여백 설정
        }
    }

    func configureView(date: Date, steps: Int, destination: String) {
        let formattedDate = formatDate(date)
        
        dateLabel.text = "방문 일자: \(formattedDate)"
        destinationLabel.text = "목적지: \(destination)"
        
        // 걸음 수 세자리마다 쉼표 추가
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let formattedSteps = numberFormatter.string(from: NSNumber(value: steps)) {
            stepsLabel.text = "걸음 수: \(formattedSteps)"
        } else {
            resultLabel.text = "Steps: \(steps)"
        }
        
        // 이미지 설정
        if let image = UIImage(named: "\(destination)") {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "태양") // 기본 이미지 설정
        }
        
        // 성공/실패 메시지 라벨 설정
        if steps >= 10000 {
            resultLabel.text = "방문 여부: 성공"
        } else {
            resultLabel.text = "방문 여부: 실패"
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // 출력 형식
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}
