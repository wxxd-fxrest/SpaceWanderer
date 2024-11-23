//
//  PlanetDetailViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/22/24.
//

import UIKit

class PlanetDetailViewController: CustomNavigationController {
    var planet: Planet? // 선택된 행성 정보
    var filteredStepData: [Date: Int] = [:] // 필터링된 데이터
        
    // 방문 성공 횟수를 표시할 레이블
    private let successCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = SpecialColors.WhiteColor
        return label
    }()
    
    // 이미지를 표시할 UIImageView
    private let planetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // 이미지를 비율에 맞게 조정
        return imageView
    }()
    
    // 행성 설명을 표시할 UILabel
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = SpecialColors.WhiteColor
        label.numberOfLines = 0 // 여러 줄을 지원하도록 설정
        return label
    }()
    
    // 방명록 버튼
    private let goGuestBookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("방명록 보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .blue // 원하는 배경색
        button.layer.cornerRadius = 5 // 모서리 둥글게
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        // UI 설정
        setupViews()
        
        // 선택된 행성 정보 및 필터링된 데이터를 표시하는 로직 추가
        if let planet = planet {
            setupView(with: planet)
            displayFilteredStepData()
            loadPlanetImage(named: planet.name) // 행성 이름으로 이미지 로드
            descriptionLabel.text = planet.description // 행성 설명 설정
        } else {
            print("선택된 행성이 없습니다.")
        }
        
        // 필터링된 데이터의 개수 출력
        print("Filtered step data count: \(filteredStepData.count)")
        
        // 방문 성공 횟수 표시
        let successCount = countSuccessfulVisits()
        successCountLabel.text = "방문 성공 횟수: \(successCount)"
        
        // 버튼 클릭 이벤트 설정
        goGuestBookButton.addTarget(self, action: #selector(navigateToGuestBook), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        // planet이 nil이 아닌 경우에만 이름을 사용
        if let planetName = planet?.name {
            setupNavigationBar(withTitle: planetName, backButtonImage: "LargeLeftIcon")
        } else {
            // planet이 nil인 경우 기본 제목 사용
            setupNavigationBar(withTitle: "행성", backButtonImage: "LargeLeftIcon")
        }
    }

    private func setupView(with planet: Planet) {
        // 행성 디테일을 표시하는 UI 구성
    }
    
    private func setupViews() {
        view.addSubview(successCountLabel)
        view.addSubview(planetImageView) // UIImageView 추가
        view.addSubview(descriptionLabel) // descriptionLabel 추가
        view.addSubview(goGuestBookButton) // 방명록 버튼 추가
        
        // 레이블의 오토 레이아웃 설정
        successCountLabel.translatesAutoresizingMaskIntoConstraints = false
        planetImageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        goGuestBookButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            successCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            successCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            planetImageView.topAnchor.constraint(equalTo: successCountLabel.bottomAnchor, constant: 20),
            planetImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planetImageView.widthAnchor.constraint(equalToConstant: 100), // 원하는 너비
            planetImageView.heightAnchor.constraint(equalToConstant: 100), // 원하는 높이
            
            descriptionLabel.topAnchor.constraint(equalTo: planetImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16), // 양쪽 여백 설정
            
            goGuestBookButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            goGuestBookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goGuestBookButton.widthAnchor.constraint(equalToConstant: 150), // 버튼 너비
            goGuestBookButton.heightAnchor.constraint(equalToConstant: 40) // 버튼 높이
        ])
    }

    private func displayFilteredStepData() {
        // 필터링된 데이터 표시하는 로직 추가
        for (date, steps) in filteredStepData {
            print("Date: \(date), Steps: \(steps)")
            // UI에 데이터 표시하는 로직 추가
        }
    }

    private func loadPlanetImage(named imageName: String) {
        // 이미지 이름에 해당하는 이미지를 Assets에서 로드
        planetImageView.image = UIImage(named: imageName)
    }

    private func countSuccessfulVisits() -> Int {
        return filteredStepData.values.filter { $0 >= 1000 }.count
    }
    
    @objc private func navigateToGuestBook() {
        let alertController = UIAlertController(title: "알림", message: "아직 개발중인 기능입니다", preferredStyle: .alert)
        
        // OK 버튼 추가
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 알림 표시
        present(alertController, animated: true, completion: nil)
        //        let guestBookVC = GuestBookViewController()
        //        guestBookVC.hidesBottomBarWhenPushed = true // 탭 바 숨기기
        //        navigationController?.pushViewController(guestBookVC, animated: true)
    }
}
