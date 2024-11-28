//
//  ProfileView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class ProfileView: UIView {
    
    // MARK: - UI Elements
    let titleLabel = UILabel()
    let downloadIcon = UIImageView(image: UIImage(named: "DownloadIcon"))
    let moreIcon = UIImageView(image: UIImage(named: "MoreVerticalIcon"))
    
    var iconsStackView: UIStackView!
    var combinedStackView: UIStackView!
    
    let cardView = UIView()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let idLabel = UILabel()
    let originLabel = UILabel()
    let birthdayLabel = UILabel()
    let descriptionLabel = UILabel()
    let starView = UIView()
    let starStackView = UIStackView()
    let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
    let starLabel = UILabel()
    
    let locationTitleLabel = UILabel()
    let locationLabel = UILabel()
    
    let totalStepsTitleLabel = UILabel()
    let totalStepsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Title Label 설정
        titleLabel.text = "PROFILE"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = SpecialColors.WhiteColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Download Icon 설정
        downloadIcon.tintColor = SpecialColors.WhiteColor
        downloadIcon.translatesAutoresizingMaskIntoConstraints = false
        downloadIcon.isUserInteractionEnabled = true
        
        // More Icon 설정
        moreIcon.tintColor = SpecialColors.WhiteColor
        moreIcon.translatesAutoresizingMaskIntoConstraints = false
        moreIcon.isUserInteractionEnabled = true
        
        // StackView 설정
        iconsStackView = UIStackView(arrangedSubviews: [downloadIcon, moreIcon])
        iconsStackView.axis = .horizontal
        iconsStackView.spacing = 8
        iconsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        combinedStackView = UIStackView(arrangedSubviews: [titleLabel, iconsStackView])
        combinedStackView.axis = .horizontal
        combinedStackView.spacing = 16
        combinedStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Parent View에 추가
        addSubview(combinedStackView)

        // Layout Constraints 설정
        NSLayoutConstraint.activate([
            iconsStackView.widthAnchor.constraint(equalToConstant: 60),
            combinedStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 14),
            combinedStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            combinedStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
        
        // Profile Card 설정
        setupProfileCard()
        
        // ETC Stack 설정
        setupETCStack()
    }
    
    private func setupProfileCard() {
        // 카드 뷰 설정
        cardView.backgroundColor = SpecialColors.WhiteColor
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        
        // Profile Image 설정
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(profileImageView)
        
        // Name Label 설정
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // ID Label 설정
        idLabel.font = UIFont.systemFont(ofSize: 14)
        idLabel.textColor = .darkGray
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Origin Label 설정
        originLabel.font = UIFont.systemFont(ofSize: 16)
        originLabel.textColor = .darkGray
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Birthday Label 설정
        birthdayLabel.font = UIFont.systemFont(ofSize: 16)
        birthdayLabel.textColor = .darkGray
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description Label 설정
        descriptionLabel.text = "위 외계인에게 우주 여행을 허가함."
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Name and ID Stack 설정
        let nameIdStackView = UIStackView(arrangedSubviews: [nameLabel, idLabel])
        nameIdStackView.axis = .horizontal
        nameIdStackView.alignment = .center
        nameIdStackView.spacing = 8
        nameIdStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Info Stack 설정
        let infoStackView = UIStackView(arrangedSubviews: [nameIdStackView, originLabel, birthdayLabel, descriptionLabel])
        infoStackView.axis = .vertical
        infoStackView.alignment = .leading
        infoStackView.spacing = 8
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(infoStackView)
        
        // Star View 설정
        starView.backgroundColor = SpecialColors.WhiteColor
        starView.layer.cornerRadius = 12
        starView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(starView)

        // Star Stack 설정
        starStackView.axis = .horizontal
        starStackView.alignment = .center
        starStackView.spacing = 4
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        starView.addSubview(starStackView)
        
        // Star Icon 설정
        starIcon.tintColor = SpecialColors.GreenStarColor
        starIcon.contentMode = .scaleAspectFit
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        starStackView.addArrangedSubview(starIcon)
        
        // Star Label 설정
        starLabel.text = "36"
        starLabel.font = UIFont.boldSystemFont(ofSize: 14)
        starLabel.textColor = SpecialColors.GreenStarColor
        starLabel.translatesAutoresizingMaskIntoConstraints = false
        starStackView.addArrangedSubview(starLabel)
        
        // Layout Constraints 설정
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.topAnchor.constraint(equalTo: combinedStackView.bottomAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            starView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            starView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -12),
            starView.widthAnchor.constraint(equalToConstant: 60),
            starView.heightAnchor.constraint(equalToConstant: 28),
            
            starStackView.centerXAnchor.constraint(equalTo: starView.centerXAnchor),
            starStackView.centerYAnchor.constraint(equalTo: starView.centerYAnchor),
            
            infoStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            infoStackView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupETCStack() {
        locationTitleLabel.text = "현 위치"
        locationTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        locationTitleLabel.textColor = SpecialColors.WhiteColor
        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        locationLabel.text = "수성"
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.textColor = SpecialColors.WhiteColor
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalStepsTitleLabel.text = "만보 달성 횟수"
        totalStepsTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        totalStepsTitleLabel.textColor = SpecialColors.WhiteColor
        totalStepsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalStepsLabel.text = "36회"
        totalStepsLabel.font = UIFont.systemFont(ofSize: 16)
        totalStepsLabel.textColor = SpecialColors.WhiteColor
        totalStepsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Location Title and Label Stack
        let locationStackView = UIStackView(arrangedSubviews: [locationTitleLabel, locationLabel])
        locationStackView.axis = .horizontal
        locationStackView.spacing = 8
        locationStackView.translatesAutoresizingMaskIntoConstraints = false

        // Total Steps Title and Label Stack
        let totalStepsStackView = UIStackView(arrangedSubviews: [totalStepsTitleLabel, totalStepsLabel])
        totalStepsStackView.axis = .horizontal
        totalStepsStackView.spacing = 8
        totalStepsStackView.translatesAutoresizingMaskIntoConstraints = false

        // Combined Stack View
        let combinedStackView = UIStackView(arrangedSubviews: [locationStackView, totalStepsStackView])
        combinedStackView.axis = .vertical
        combinedStackView.alignment = .fill
        combinedStackView.spacing = 16 // Vertical spacing
        combinedStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to Parent View
        addSubview(combinedStackView)

        // Layout Constraints for Combined Stack View
        NSLayoutConstraint.activate([
            combinedStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            combinedStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 28),
            combinedStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            combinedStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
