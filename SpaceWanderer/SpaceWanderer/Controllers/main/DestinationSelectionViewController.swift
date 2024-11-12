//
//  DestinationSelectionViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/12/24.
//

import UIKit
import Foundation

struct Planet: Decodable {
    let id: String
    let name: String
    let description: String
    let imageUrl: String
    let requiredSteps: Int
}

// 서버에서 받는 요청을 위해 planetName을 감싸는 구조체 생성
struct PlanetUpdateRequest: Codable {
    let planetName: String
}

class DestinationSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var userIdentifier: String?
    
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
        print("행성 선택 userIdentifier", userIdentifier)
        setupTableView()
        fetchPlanets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // 테이블 뷰 설정
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        // 테이블 뷰에 커스텀 셀 등록
        tableView.register(PlanetCell.self, forCellReuseIdentifier: "PlanetCell")
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let planet = planets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanetCell", for: indexPath) as! PlanetCell
        
        // 셀 데이터 설정
        cell.planetNameLabel.text = planet.name
        print("planet.name", planet.id)
        
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        planetNameLabel = UILabel()
        planetImageView = UIImageView()
        
        // 셀 내부 UI 구성
        planetNameLabel.translatesAutoresizingMaskIntoConstraints = false
        planetImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(planetNameLabel)
        contentView.addSubview(planetImageView)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            planetImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            planetImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            planetImageView.widthAnchor.constraint(equalToConstant: 50),
            planetImageView.heightAnchor.constraint(equalToConstant: 50),
            
            planetNameLabel.leadingAnchor.constraint(equalTo: planetImageView.trailingAnchor, constant: 10),
            planetNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


