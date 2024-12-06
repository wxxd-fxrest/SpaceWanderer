//
//  ProfileView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit
import Then

class ProfileView: UIView {
    
    // MARK: - UI Elements
    lazy var titleLabel = UIFactory.makeLabel(text: "PROFILE", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .bold, size: 20, isScaled: true), textAlignment: .left)
    var downloadIcon = UIFactory.makeImageView(imageName: "DownloadIcon", color: SpecialColors.WhiteColor)
    var moreIcon = UIFactory.makeImageView(imageName: "MoreVerticalIcon", color: SpecialColors.WhiteColor)
    lazy var iconsStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [downloadIcon, moreIcon],
        axis: .horizontal,
        spacing: 8,
        alignment: .leading,
        distribution: .fill
    )
    lazy var combinedStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [titleLabel, iconsStackView],
        axis: .horizontal,
        spacing: 16,
        alignment: .leading,
        distribution: .fill
    )
    
    lazy var cardView = UIFactory.makeView(backgroundColor: SpecialColors.WhiteColor, cornerRadius: 12)
    lazy var profileImageBackView = UIFactory.makeView(backgroundColor: SpecialColors.MainColor.withAlphaComponent(0.3), cornerRadius: 30)
    let profileImageView = UIImageView()
    
    lazy var nameLabel = UIFactory.makeLabel(text: "name", textColor: SpecialColors.MainViewBackGroundColor, font: UIFont.pretendard(style: .bold, size: 20, isScaled: true), textAlignment: .left)
    lazy var idLabel = UIFactory.makeLabel(text: "id", textColor: SpecialColors.GearGray, font: UIFont.pretendard(style: .regular, size: 14, isScaled: true), textAlignment: .left)
    lazy var nameIdStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [nameLabel, idLabel],
        axis: .horizontal,
        spacing: 8,
        alignment: .center,
        distribution: .fill
    )
    
    lazy var originLabel = UIFactory.makeLabel(text: "origin", textColor: SpecialColors.GearGray, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .left)
    lazy var birthdayLabel = UIFactory.makeLabel(text: "birthday", textColor: SpecialColors.GearGray, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .left)
    lazy var systemLabel = UIFactory.makeLabel(text: "위 외계인에게 우주 여행을 허가함.", textColor: SpecialColors.GearGray, font: UIFont.pretendard(style: .regular, size: 14, isScaled: true), textAlignment: .left)
    lazy var infoStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [nameIdStackView, originLabel, birthdayLabel, systemLabel],
        axis: .vertical,
        spacing: 8,
        alignment: .leading,
        distribution: .fill
    )
    
    lazy var starView = UIFactory.makeView(backgroundColor: SpecialColors.GreenStarColor, cornerRadius: 12)
    lazy var starStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [starIcon, starLabel],
        axis: .horizontal,
        spacing: 8,
        alignment: .center,
        distribution: .fill
    )
    var starIcon = UIFactory.makeImageView(imageName: "star.fill", color: SpecialColors.WhiteColor)
    lazy var starLabel = UIFactory.makeLabel(text: "0", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .semiBold, size: 16, isScaled: true), textAlignment: .left)

    lazy var locationTitleLabel = UIFactory.makeLabel(text: "현 위치", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .left)
    lazy var locationLabel = UIFactory.makeLabel(text: "수성", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .bold, size: 16, isScaled: true), textAlignment: .left)
    lazy var locationStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [locationTitleLabel, locationLabel],
        axis: .horizontal,
        spacing: 8,
        alignment: .fill,
        distribution: .fill
    )
    
    lazy var totalStepsTitleLabel = UIFactory.makeLabel(text: "만보 달성 횟수", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .left)
    lazy var totalStepsLabel = UIFactory.makeLabel(text: "0 회", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .bold, size: 16, isScaled: true), textAlignment: .left)
    lazy var totalStepsStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [totalStepsTitleLabel, totalStepsLabel],
        axis: .horizontal,
        spacing: 8,
        alignment: .fill,
        distribution: .fill
    )
    
    lazy var totalCombinedStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [locationStackView, totalStepsStackView],
        axis: .vertical,
        spacing: 16,
        alignment: .center,
        distribution: .fill
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
        downloadIcon.isUserInteractionEnabled = true
        moreIcon.isUserInteractionEnabled = true
        
        // Parent View에 추가
        addSubviews(combinedStackView, cardView, totalCombinedStackView)

        iconsStackView.snp.makeConstraints {
            $0.width.equalTo(60)
        }

        combinedStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(14)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // Profile Card 설정
        setupProfileCard()
        
        // ETC Stack 설정
        setupETCStack()
    }
    
    private func setupProfileCard() {
        // Profile Image 설정
        cardView.addSubviews(profileImageBackView, infoStackView, starView)
        profileImageBackView.addSubview(profileImageView)
        starView.addSubview(starStackView)

        cardView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(combinedStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        profileImageBackView.snp.makeConstraints {
            $0.leading.equalTo(cardView.snp.leading).offset(24)
            $0.top.equalTo(cardView.snp.top).offset(30)
            $0.width.equalTo(80)
            $0.height.equalTo(80)
        }
        
        profileImageView.snp.makeConstraints {
            $0.center.equalTo(profileImageBackView) // imageBackView의 중앙에 배치
            $0.edges.equalToSuperview().inset(12) // imageBackView 내부 여백 설정
        }

        starView.snp.makeConstraints {
            $0.centerX.equalTo(profileImageView.snp.centerX)
            $0.top.equalTo(profileImageBackView.snp.bottom).offset(-12)
            $0.width.equalTo(60)
            $0.height.equalTo(28)
        }

        starStackView.snp.makeConstraints {
            $0.centerX.equalTo(starView.snp.centerX)
            $0.centerY.equalTo(starView.snp.centerY)
        }
        
        starIcon.snp.makeConstraints {
            $0.width.equalTo(18)
            $0.height.equalTo(18)
        }

        infoStackView.snp.makeConstraints {
            $0.leading.equalTo(profileImageBackView.snp.trailing).offset(26)
            $0.trailing.equalTo(cardView.snp.trailing).offset(-24)
            $0.centerY.equalTo(cardView)
            $0.bottom.lessThanOrEqualTo(cardView.snp.bottom).offset(-30)
        }
    }
    
    private func setupETCStack() {
        totalStepsStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(totalCombinedStackView)
        }
        
        locationStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(totalCombinedStackView)
        }
        
        totalCombinedStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(cardView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)  // 좌우 여백 20
        }
    }
}
