//
//  DestinationSelectionViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/12/24.
//

import UIKit
import Foundation

class DestinationSelectionViewController: CustomNavigationController, UITableViewDelegate, UITableViewDataSource {
    var userIdentifier: String?
    var totalGoals: String?
    
    var tableView: UITableView!
    var planets: [Planet] = [] // 서버에서 받아올 행성 목록
    
    lazy var backendURL: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["PLANET_BASE_URL"] as? String {
            print("PLANET_BASE_URL", backendURL)
            
            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()
    
    lazy var backendURL2: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["PROFILE_BASE_URL"] as? String {
            print("PROFILE_BASE_URL", backendURL)
            
            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DestinationSelectionViewController userIdentifier: ", userIdentifier)
        print("DestinationSelectionViewController totalGoals: ", totalGoals)
        print("totalGoals: \(totalGoals ?? "nil")")
        
        setupTableView()
        fetchPlanets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // 인스턴스 메서드로 호출
        setupNavigationBar(withTitle: "목적지 선택", backButtonImage: "LargeLeftIcon")
    }
    
    // 테이블 뷰 설정
    private func setupTableView() {
        tableView = UITableView()
        tableView.backgroundColor = SpecialColors.MainViewBackGroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        // 테이블 뷰에 커스텀 셀 등록
        tableView.register(PlanetCell.self, forCellReuseIdentifier: "PlanetCell")
        
        // 구분선 색상 설정
        tableView.separatorColor = .darkGray // 원하는 색으로 변경
        
        view.addSubview(tableView)
        
        // 테이블 뷰 레이아웃 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // API 호출로 행성 목록 가져오기
    private func fetchPlanets() {
        guard let url = URL(string: "\(backendURL)/get-all-planet") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching planets: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // JSON 디코딩
                let decoder = JSONDecoder()
                let planets = try decoder.decode([Planet].self, from: data)
                
                DispatchQueue.main.async {
                    self.planets = planets
                    self.tableView.reloadData() // 데이터 갱신 후 테이블 뷰 업데이트
                    
                    print("planet.requiredSteps: \(planets)")
                }
            } catch {
                print("Error decoding planets: \(error)")
            }
        }
        
        task.resume()
    }
    
    // UITableViewDelegate & UITableViewDataSource 구현
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planets.count
    }
    
    // UITableViewDelegate 구현
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // 원하는 셀 높이
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let planet = planets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanetCell", for: indexPath) as! PlanetCell
        
        // 셀 데이터 설정
        cell.planetNameLabel.text = planet.name
        
        cell.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        // 이미지 설정 (assets에 있는 이미지 이름과 일치해야 함)
        cell.planetImageView.image = UIImage(named: planet.planetImage) // imageUrl에 해당하는 이미지를 로드
        
        // requiredSteps 설정
        cell.requiredStepsLabel.text = "필요 단계: \(planet.stepsRequired)" // 필요한 단계 표시
        
        // totalGoals와 steps_required 비교
        if let totalGoalsInt = Int(totalGoals ?? "0"), totalGoalsInt >= planet.stepsRequired {
            // 조건 만족: 클릭 가능
            cell.planetNameLabel.textColor = SpecialColors.WhiteColor // 기본 색상
            cell.requiredStepsLabel.textColor = SpecialColors.WhiteColor // 기본 색상
            cell.isUserInteractionEnabled = true
        } else {
            // 조건 불만족: 클릭 불가능
            cell.planetNameLabel.textColor = .darkGray // 빨간색
            cell.requiredStepsLabel.textColor = .darkGray // 기본 색상
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlanet = planets[indexPath.row]
        
        // 서버에 선택한 행성 이름을 보내기
        updateUserPlanet(with: selectedPlanet.name)
        
        // 뒤로 이동
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updateUserPlanet(with planetName: String) {
        guard let userIdentifier = userIdentifier else { return }
        
        guard let url = URL(string: "\(backendURL2)/update-planet/\(userIdentifier)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // planetName을 직접 문자열로 전송
        let requestBody: [String: String] = ["destinationPlanet": planetName] // 키-값 쌍으로 전송
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding request body: \(error)")
            return
        }
        
        // 서버 요청
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating user's planet: \(error)")
                return
            }
            
            if let data = data {
                // 응답 데이터 처리 (필요한 경우)
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("User's planet updated successfully.")
                        // NotificationCenter를 통해 알림 게시
                        NotificationCenter.default.post(name: .planetUpdatedMain, object: nil)
                        NotificationCenter.default.post(name: .planetUpdatedCalendar, object: nil)
                        NotificationCenter.default.post(name: .planetUpdatedTabBar, object: nil)
                        
                        // 추가: 데이터 다시 가져오기
                        DispatchQueue.main.async {
                            // Notification을 수신한 후 fetchStepData 호출
                            NotificationCenter.default.post(name: .planetUpdatedMain, object: nil)
                            NotificationCenter.default.post(name: .planetUpdatedCalendar, object: nil)
                            NotificationCenter.default.post(name: .planetUpdatedTabBar, object: nil)
                        }
                    } else {
                        print("Failed to update planet. Status code: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
}

class PlanetCell: UITableViewCell {
    var planetNameLabel: UILabel!
    var planetImageView: UIImageView!
    var requiredStepsLabel: UILabel! // 최소 성공 횟수 라벨 추가

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        planetNameLabel = UILabel()
        planetImageView = UIImageView()
        requiredStepsLabel = UILabel() // 라벨 초기화
        
        // 셀 내부 UI 구성
        planetNameLabel.translatesAutoresizingMaskIntoConstraints = false
        planetImageView.translatesAutoresizingMaskIntoConstraints = false
        requiredStepsLabel.translatesAutoresizingMaskIntoConstraints = false // 라벨 제약 설정
        
        contentView.addSubview(planetNameLabel)
        contentView.addSubview(planetImageView)
        contentView.addSubview(requiredStepsLabel) // 라벨 추가
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            planetImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            planetImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            planetImageView.widthAnchor.constraint(equalToConstant: 24),
            planetImageView.heightAnchor.constraint(equalToConstant: 24),
            
            planetNameLabel.leadingAnchor.constraint(equalTo: planetImageView.trailingAnchor, constant: 10),
            planetNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            requiredStepsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15), // 오른쪽 여백
            requiredStepsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor) // 세로 중앙 정렬
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Notification.Name {
    static let planetUpdatedMain = Notification.Name("PlanetUpdatedMain")
    static let planetUpdatedCalendar = Notification.Name("PlanetUpdatedCalendar")
    static let planetUpdatedTabBar = Notification.Name("PlanetUpdatedTabbar")
}
