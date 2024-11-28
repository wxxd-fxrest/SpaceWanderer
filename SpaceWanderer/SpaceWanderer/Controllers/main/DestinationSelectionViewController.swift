//
//  DestinationSelectionViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/12/24.
//

import UIKit

class DestinationSelectionViewController: CustomNavigationController {
    var userIdentifier: String?
    var totalGoals: String?
    
    var planets: [Planet] = [] // 서버에서 받아올 행성 목록
    
    private var destinationSelectionView: DestinationSelectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DestinationSelectionViewController userIdentifier: ", userIdentifier)
        print("DestinationSelectionViewController totalGoals: ", totalGoals)
        print("totalGoals: \(totalGoals ?? "nil")")
        
        setupUI()
        fetchPlanets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(withTitle: "목적지 선택", backButtonImage: "LargeLeftIcon")
    }
    
    private func setupUI() {
        // DestinationSelectionView 인스턴스화
        destinationSelectionView = DestinationSelectionView(frame: self.view.bounds)
        destinationSelectionView.tableView.delegate = self
        destinationSelectionView.tableView.dataSource = self
        destinationSelectionView.tableView.register(PlanetCell.self, forCellReuseIdentifier: "PlanetCell")
        view.addSubview(destinationSelectionView)
    }

    // API 호출로 행성 목록 가져오기
    private func fetchPlanets() {
        PlanetAPIManager.shared.fetchPlanets { result in
            switch result {
            case .success(let planets):
                DispatchQueue.main.async {
                    self.planets = planets
                    self.destinationSelectionView.tableView.reloadData() // 데이터 갱신 후 테이블 뷰 업데이트
                    print("planet.requiredSteps: \(planets)")
                }
            case .failure(let error):
                print("Error fetching planets: \(error)")
            }
        }
    }
    
    func updateUserPlanet(with planetName: String) {
        guard let userIdentifier = userIdentifier else { return }
        
        UserAPIManager.shared.updateUserPlanet(userIdentifier: userIdentifier, planetName: planetName) { result in
            switch result {
            case .success:
                print("User's planet updated successfully.")
                
                // NotificationCenter를 통해 알림 게시
                NotificationCenter.default.post(name: .planetUpdatedMain, object: nil)
                NotificationCenter.default.post(name: .planetUpdatedCalendar, object: nil)
                NotificationCenter.default.post(name: .planetUpdatedTabBar, object: nil)
                
            case .failure(let error):
                print("Error updating user's planet: \(error)")
            }
        }
    }
}
