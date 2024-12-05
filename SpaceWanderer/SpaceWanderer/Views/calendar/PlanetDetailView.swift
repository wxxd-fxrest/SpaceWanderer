//
//  PlanetDetailView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit
import Then

class PlanetDetailView: UIView {
    
    let topPadding: CGFloat = 8.0
    let bottomPadding: CGFloat = 8.0
    
    // MARK: - UI Elements
    lazy var successCountTitleLabel = UIFactory.makeLabel(text: "방문 성공 횟수", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .regular, size: 18, isScaled: true), textAlignment: .center)
    lazy var successCountBackView = UIFactory.makeView(backgroundColor: SpecialColors.MainColor, cornerRadius: 12)
    lazy var successCountLabel = UIFactory.makeLabel(text: "success count", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .regular, size: 18, isScaled: true), textAlignment: .center)
    lazy var successCountStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [successCountTitleLabel, successCountBackView],
        axis: .horizontal,
        spacing: 20,
        alignment: .fill,
        distribution: .equalSpacing
    )
    
    lazy var descriptionBackView = UIFactory.makeView(backgroundColor: SpecialColors.WhiteColor, cornerRadius: 12)
    lazy var descriptionLabel = UIFactory.makeLabel(text: "description", textColor: SpecialColors.MainViewBackGroundColor, font: UIFont.pretendard(style: .regular, size: 18, isScaled: true), textAlignment: .center)
    
    // Image
    lazy var imageBackView = UIFactory.makeView(backgroundColor: SpecialColors.MainViewBackGroundColor.withAlphaComponent(0.2), cornerRadius: 12)
    lazy var imageInnerBackView = UIFactory.makeView(backgroundColor: SpecialColors.MainViewBackGroundColor, cornerRadius: 8)
    let planetImageView = UIImageView() // 이미지 뷰 추가
    
    lazy var stackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [planetImageView, descriptionBackView, successCountStackView],
        axis: .vertical,
        spacing: 34,
        alignment: .center,
        distribution: .fill
    )

    // goGuestBookButton은 나중에 개발
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
        addSubviews(stackView)
        successCountBackView.addSubview(successCountLabel)
        descriptionBackView.addSubview(descriptionLabel)
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(34)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        planetImageView.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.height.equalTo(120)
        }
        
        successCountStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(stackView)
        }
        
        successCountBackView.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.leading.equalTo(successCountLabel).offset(-8) // 여백을 설정해서 label의 왼쪽에 여백을 추가
            $0.trailing.equalTo(successCountLabel).offset(8) // 여백을 설정해서 label의 오른쪽에 여백을 추가
        }

        successCountLabel.snp.makeConstraints {
            $0.center.equalTo(successCountBackView) // successCountBackView의 중앙에 배치
        }

        descriptionBackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(stackView)
            $0.height.equalTo(descriptionLabel.snp.height).offset(topPadding + bottomPadding) // 패딩을 포함한 높이
        }

        descriptionLabel.snp.makeConstraints {
            $0.center.equalTo(descriptionBackView) // descriptionBackView의 중앙에 배치
            $0.top.equalTo(descriptionBackView.snp.top).offset(topPadding) // 상단 패딩
            $0.bottom.equalTo(descriptionBackView.snp.bottom).offset(-bottomPadding) // 하단 패딩
        }
    }

    func configureView(planet: Planet, filteredStepData: [Date: Int]) {
        // 행성 정보를 설정
        successCountLabel.text = String(format: "%02d", countSuccessfulVisits(filteredStepData: filteredStepData))
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
