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

    private let planetDetailView = PlanetDetailView() // PlanetDetailView 인스턴스

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        // UI 설정
        setupViews()
        
        // 선택된 행성 정보 및 필터링된 데이터를 표시하는 로직 추가
        if let planet = planet {
            planetDetailView.configureView(planet: planet, filteredStepData: filteredStepData)
        } else {
            print("선택된 행성이 없습니다.")
        }
        
        // 방문 성공 횟수 출력
        print("Filtered step data count: \(filteredStepData.count)")
        
        // 버튼 클릭 이벤트 설정
        planetDetailView.goGuestBookButton.addTarget(self, action: #selector(navigateToGuestBook), for: .touchUpInside)
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

    private func setupViews() {
        view.addSubview(planetDetailView)
        planetDetailView.frame = view.bounds // 전체 화면에 맞게 설정
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
