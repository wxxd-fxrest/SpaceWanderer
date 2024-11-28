//
//  PlanetDetailView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class PlanetDetailView: UIView {
    
    // MARK: - UI Elements
    let successCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = SpecialColors.WhiteColor
        return label
    }()
    
    let planetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // 이미지를 비율에 맞게 조정
        return imageView
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = SpecialColors.WhiteColor
        label.numberOfLines = 0 // 여러 줄을 지원하도록 설정
        return label
    }()
    
    let goGuestBookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("방명록 보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .blue // 원하는 배경색
        button.layer.cornerRadius = 5 // 모서리 둥글게
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(successCountLabel)
        addSubview(planetImageView)
        addSubview(descriptionLabel)
        addSubview(goGuestBookButton)
        
        // 레이블의 오토 레이아웃 설정
        successCountLabel.translatesAutoresizingMaskIntoConstraints = false
        planetImageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        goGuestBookButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            successCountLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            successCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            planetImageView.topAnchor.constraint(equalTo: successCountLabel.bottomAnchor, constant: 20),
            planetImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            planetImageView.widthAnchor.constraint(equalToConstant: 100), // 원하는 너비
            planetImageView.heightAnchor.constraint(equalToConstant: 100), // 원하는 높이
            
            descriptionLabel.topAnchor.constraint(equalTo: planetImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16), // 양쪽 여백 설정
            
            goGuestBookButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            goGuestBookButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            goGuestBookButton.widthAnchor.constraint(equalToConstant: 150), // 버튼 너비
            goGuestBookButton.heightAnchor.constraint(equalToConstant: 40) // 버튼 높이
        ])
    }

    func configureView(planet: Planet, filteredStepData: [Date: Int]) {
        // 행성 정보를 설정
        successCountLabel.text = "방문 성공 횟수: \(countSuccessfulVisits(filteredStepData: filteredStepData))"
        descriptionLabel.text = planet.description // 행성 설명 설정
        loadPlanetImage(named: planet.name) // 행성 이름으로 이미지 로드
    }
    
    private func loadPlanetImage(named imageName: String) {
        // 이미지 이름에 해당하는 이미지를 Assets에서 로드
        planetImageView.image = UIImage(named: imageName)
    }
    
    private func countSuccessfulVisits(filteredStepData: [Date: Int]) -> Int {
        return filteredStepData.values.filter { $0 >= 1000 }.count
    }
}
