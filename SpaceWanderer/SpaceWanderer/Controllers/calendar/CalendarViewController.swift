//
//  CalendarViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/5/24.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {
    var userUniqueId: String?
    var userIdentifier: String?
    var totalGoals: String?

    // MARK: - 캘린더 컬렉션
    private let calendar = Calendar.current
    private var dates = [Date]() // 달력에 표시할 날짜 목록
    private var stepData: [Date: (Int, String)] = [:] // 날짜별 걸음 수와 행성 정보 데이터
    private var selectedDate = Date()
    
    //MARK: - 행성 컬렉션
    var planets: [Planet] = []
    
    // MARK: - CollectionView
    // CalendarCollectionView
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        collectionView.backgroundColor = SpecialColors.MainViewBackGroundColor
        return collectionView
    }()
    
    // PlanetCollectionView
    private lazy var planetCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemsPerRow: CGFloat = 4 // 한 줄에 4개
        let spacing: CGFloat = 10   // 셀 간 간격
        let totalSpacing = spacing * (itemsPerRow - 1) + 32 // 양쪽 여백(16 + 16)
        let itemWidth = (view.frame.width - totalSpacing) / itemsPerRow

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        layout.scrollDirection = .vertical // 세로 방향으로 설정

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarPlanetCell.self, forCellWithReuseIdentifier: "CalendarPlanetCell")
        collectionView.backgroundColor = SpecialColors.MainViewBackGroundColor
        collectionView.isScrollEnabled = false // 스크롤 비활성화
        return collectionView
    }()
    
    // MARK: - UI
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let totalStepsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // Planet
    private let planetLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // MARK: - Base URL
    lazy var backendURL: String = {
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
    
    lazy var planetBackendURL: String = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        setupViews()
        setupDates()
        updateMonthLabel()
        updateTotalStepsLabel()
        updatePlanetLabel()

        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        
        guard let userUniqueId = userUniqueId else {
            print("User Unique ID is missing.")
            return
        }
        
        fetchStepData(for: userUniqueId, year: year, month: month)
        fetchPlanets()
        
        // 년월 표시 클릭 이벤트
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMonthSelectionModal))
        monthLabel.addGestureRecognizer(tapGesture)
        
        print("CalendarViewController totalGoals: ", totalGoals)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupViews() {
        view.addSubview(monthLabel)
        view.addSubview(totalStepsLabel)
        view.addSubview(calendarCollectionView)
        view.addSubview(planetCollectionView) // 행성 컬렉션 뷰 추가
        view.addSubview(planetLabel) // 행성 라벨 추가
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        totalStepsLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        planetCollectionView.translatesAutoresizingMaskIntoConstraints = false
        planetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            totalStepsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            totalStepsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            calendarCollectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
            calendarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarCollectionView.heightAnchor.constraint(equalToConstant: 300), // collectionView 높이 설정
            
            planetLabel.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 10),
            planetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            planetCollectionView.topAnchor.constraint(equalTo: planetLabel.bottomAnchor, constant: 20),
            planetCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            planetCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            planetCollectionView.heightAnchor.constraint(equalToConstant: 200) // 높이 직접 지정
        ])
    }
    
    private func setupDates() {
        // 이번 달의 날짜들을 계산해서 dates 배열에 추가
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let startOfMonth = calendar.date(from: components) else { return }
        
        dates.removeAll()
        for day in 0..<calendar.range(of: .day, in: .month, for: startOfMonth)!.count {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfMonth) {
                dates.append(date)
            }
        }
    }
    
    // MARK: - Calendar
    // MARK: GET: 한달 간격의 캘린더 데이터 가져오기
    func fetchStepData(for userUniqueId: String, year: Int, month: Int) {
        print("fetchStepData userUniqueId: ", userUniqueId, year, month)
        // 서버 URL 설정
        let url = URL(string: "\(backendURL)/calendar/steps/\(userUniqueId)?year=\(year)&month=\(month)")!
        var request = URLRequest(url: url)
        print("url", url)
        request.httpMethod = "GET"
        
        // 네트워크 요청 보내기
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching step data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            // 서버에서 받은 데이터를 파싱하여 stepData 배열에 저장
            do {
                let stepData = try JSONDecoder().decode([StepRequest].self, from: data)
                print("stepData: ", stepData)
                DispatchQueue.main.async {
                    self.stepData = self.convertStepEntitiesToDictionary(stepData)
                    self.updateTotalStepsLabel()
                    self.calendarCollectionView.reloadData()
                }
            } catch {
                print("Error decoding step data: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    // JSON을 StepEntity 객체로 변환
    private func convertStepEntitiesToDictionary(_ stepEntities: [StepRequest]) -> [Date: (Int, String)] {
        var stepData: [Date: (Int, String)] = [:]
        
        for entity in stepEntities {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let dateObj = formatter.date(from: entity.walkingDate) {
                // daySteps를 Int로 변환하여 저장
                stepData[dateObj] = (Int(entity.daySteps), entity.dayDestination)
            }
        }
        
        return stepData
    }
    
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        monthLabel.text = formatter.string(from: selectedDate)
    }
    
    private func updateTotalStepsLabel() {
        let totalSteps = dates.reduce(0) { $0 + (stepData[$1]?.0 ?? 0) }  // 튜플의 첫 번째 값인 Int만 사용
        totalStepsLabel.text = "총 걸음 수: \(totalSteps)"
    }
    
    private func updatePlanetLabel() {
        planetLabel.text = "Planet"
    }
    
    @objc private func showMonthSelectionModal() {
        let monthSelectionVC = MonthSelectionViewController()
        monthSelectionVC.delegate = self
        monthSelectionVC.selectedDate = selectedDate
        monthSelectionVC.modalPresentationStyle = .custom
        monthSelectionVC.transitioningDelegate = self // 바텀 시트 표시를 위해 필요
        
        present(monthSelectionVC, animated: true, completion: nil)
    }
    
    // MARK: - Planet
    private func fetchPlanets() {
        guard let url = URL(string: "\(planetBackendURL)/get-all-planet") else { return }
        
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
                    self.planetCollectionView.reloadData()
                }
            } catch {
                print("Error decoding planets: \(error)")
            }
        }
        
        task.resume()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.planetCollectionView {
            return planets.count // Ensure this returns the correct count
        } else {
            return dates.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.calendarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
            let date = dates[indexPath.item]
         
            // stepData에서 값을 가져올 때 튜플의 첫 번째 값인 Int만 사용
            let steps = stepData[date]?.0 ?? 0  // steps.0으로 Int 값만 가져옴
            
            cell.configure(date: date, steps: steps)
            return cell
        } else if collectionView == self.planetCollectionView {
            // 인덱스가 범위 내에 있는지 확인
            guard indexPath.item < planets.count else {
                fatalError("\(indexPath.item) 행성 배열의 경우 범위를 벗어난 인덱스입니다.")
            }
            
            let planet = planets[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarPlanetCell", for: indexPath) as! CalendarPlanetCell
            
            // 행성 셀 구성
            cell.configure(planet: planet.name)
            
            // 조건 확인: totalGoals >= stepsRequired
            if let totalGoalsInt = Int(totalGoals ?? "0"), totalGoalsInt >= planet.requiredSteps {
                // 조건 만족: 클릭 가능, 글자 색상 기본
                cell.planetLabel.textColor = .white
                cell.isUserInteractionEnabled = true
            } else {
                // 조건 불만족: 클릭 불가능, 글자 색상 빨간색
                cell.planetLabel.textColor = .darkGray
                cell.isUserInteractionEnabled = false
            }
            
            return cell
        }
        fatalError("예상치 못한 컬렉션 보기")
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 16) / 7 // 7일이 일주일
        return CGSize(width: width, height: width)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.calendarCollectionView {
          let selectedDate = dates[indexPath.item]
          navigateToDetailPage(for: selectedDate)
        } else if collectionView == self.planetCollectionView {
            let selectedPlanet = planets[indexPath.item]
            print("Selected planet: \(selectedPlanet)")
            // 선택된 행성을 처리하는 로직 추가
        }
    }
    
    private func navigateToDetailPage(for date: Date) {
        let detailVC = StepDetailViewController()
        let stepDataForSelectedDate = stepData[date] ?? (0, "")
        detailVC.date = date
        detailVC.steps = stepDataForSelectedDate.0 // Step count
        detailVC.dayDestination = stepDataForSelectedDate.1 // Day destination
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension CalendarViewController: UIViewControllerTransitioningDelegate, MonthSelectionViewControllerDelegate {
    // MARK: -  UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    // MARK: - MonthSelectionViewControllerDelegate
    func didSelectDate(_ date: Date) {
        selectedDate = date
        setupDates()
        
        // 선택된 년/월에 대한 데이터 요청
        let year = Calendar.current.component(.year, from: selectedDate)
        let month = Calendar.current.component(.month, from: selectedDate)
        fetchStepData(for: userUniqueId ?? "", year: year, month: month)
        
        updateMonthLabel()
        updateTotalStepsLabel()
    }
}

//import UIKit
//
//class CalendarViewController: UIViewController, UIViewControllerTransitioningDelegate {
//    var userUniqueId: String?
//    var userIdentifier: String?
//    
//    // Calendar
//    var selectedDate = Date()
//    private var dates = [Date]() // 달력에 표시할 날짜 목록
//    private var stepData: [Date: (Int, String)] = [:] // 날짜별 걸음 수와 행성 정보 데이터
//    
//    // Planet
//    private var planets: [Planet] = []
//    // var planets: [Planet] = [] // 서버에서 받아올 행성 목록
//
    // MARK: - CollectionView
    // CalendarCollectionView
//    private lazy var calendarCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = 2
//        layout.minimumInteritemSpacing = 2
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
//        collectionView.backgroundColor = SpecialColors.MainViewBackGroundColor
//        return collectionView
//    }()
//    
//    // PlanetCollectionView
//    private lazy var planetCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        let itemsPerRow: CGFloat = 4
//        let spacing: CGFloat = 10
//        let totalSpacing = spacing * (itemsPerRow - 1) + 32
//        let itemWidth = (view.frame.width - totalSpacing) / itemsPerRow
//
//        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
//        layout.minimumInteritemSpacing = spacing
//        layout.minimumLineSpacing = spacing
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
//        layout.scrollDirection = .vertical
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(CalendarPlanetCell.self, forCellWithReuseIdentifier: "CalendarPlanetCell")
//        collectionView.backgroundColor = SpecialColors.MainViewBackGroundColor
//        return collectionView
//    }()
//    
//    // MARK: - UI
//    private let monthLabel: UILabel = {
//        let label = UILabel()
//        label.font = .boldSystemFont(ofSize: 18)
//        label.textColor = .white
//        label.isUserInteractionEnabled = true
//        return label
//    }()
//    
//    private let totalStepsLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .white
//        return label
//    }()
//    
//    // Planet
//    private let planetLabel: UILabel = {
//        let label = UILabel()
//        label.font = .boldSystemFont(ofSize: 18)
//        label.textColor = .white
//        label.isUserInteractionEnabled = true
//        return label
//    }()
//    
//    // MARK: - Base URL
//    lazy var backendURL: String = {
//        // Space.plist에서 BackendURL 가져오기
//        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
//           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
//           let backendURL = spaceDict["PROFILE_BASE_URL"] as? String {
//            return backendURL
//        } else {
//            return "http://localhost:1020" // 기본값 설정
//        }
//    }()
//
//    // MARK: - ViewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = SpecialColors.MainViewBackGroundColor
//        
//        setupViews()
//        setupDates()
//        updateMonthLabel()
//        updateTotalStepsLabel()
//
//        let year = Calendar.current.component(.year, from: selectedDate)
//        let month = Calendar.current.component(.month, from: selectedDate)
//        
//        guard let userUniqueId = userUniqueId else {
//            print("User Unique ID is missing.")
//            return
//        }
//        
//        fetchStepData(for: userUniqueId, year: year, month: month)
//        fetchPlanets()
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMonthSelectionModal))
//        monthLabel.addGestureRecognizer(tapGesture)
//    }
//    
//    // MARK: - ViewWillAppear
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//    
//    // MARK: - Setup Views
//    private func setupViews() {
//        view.addSubview(monthLabel)
//        view.addSubview(totalStepsLabel)
//        view.addSubview(calendarCollectionView)
//        view.addSubview(planetCollectionView) // 행성 컬렉션 뷰 추가
//        view.addSubview(planetLabel) // 행성 라벨 추가
//        
//        monthLabel.translatesAutoresizingMaskIntoConstraints = false
//        totalStepsLabel.translatesAutoresizingMaskIntoConstraints = false
//        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        planetCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        planetLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            
//            totalStepsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
//            totalStepsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            calendarCollectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
//            calendarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            calendarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            calendarCollectionView.heightAnchor.constraint(equalToConstant: 300), // collectionView 높이 설정
//            
//            planetLabel.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 10),
//            planetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//
//            planetCollectionView.topAnchor.constraint(equalTo: planetLabel.bottomAnchor, constant: 20),
//            planetCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            planetCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            planetCollectionView.heightAnchor.constraint(equalToConstant: 200) // 높이 직접 지정
//        ])
//    }
//    
//    private func setupDates() {
//        let components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
//        guard let startOfMonth = Calendar.current.date(from: components) else { return }
//        
//        dates.removeAll()
//        for day in 0..<Calendar.current.range(of: .day, in: .month, for: startOfMonth)!.count {
//            if let date = Calendar.current.date(byAdding: .day, value: day, to: startOfMonth) {
//                dates.append(date)
//            }
//        }
//    }
//
//    // MARK: - Calendar
//    // MARK: GET: 한달 간격의 캘린더 데이터 가져오기
//    func fetchStepData(for userUniqueId: String, year: Int, month: Int) {
//        let url = URL(string: "\(backendURL)/calendar/steps/\(userUniqueId)?year=\(year)&month=\(month)")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error fetching step data: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let data = data else { return }
//            
//            do {
//                let stepData = try JSONDecoder().decode([StepRequest].self, from: data)
//                DispatchQueue.main.async {
//                    self.stepData = self.convertStepEntitiesToDictionary(stepData)
//                    self.updateTotalStepsLabel()
//                    self.calendarCollectionView.reloadData()
//                }
//            } catch {
//                print("Error decoding step data: \(error.localizedDescription)")
//            }
//        }
//        
//        task.resume()
//    }
//
//    private func convertStepEntitiesToDictionary(_ stepEntities: [StepRequest]) -> [Date: (Int, String)] {
//        var stepData: [Date: (Int, String)] = [:]
//        
//        for entity in stepEntities {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd"
//            if let dateObj = formatter.date(from: entity.walkingDate) {
//                stepData[dateObj] = (Int(entity.daySteps), entity.dayDestination)
//            }
//        }
//        
//        return stepData
//    }
//
//    private func updateMonthLabel() {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy년 MM월"
//        monthLabel.text = formatter.string(from: selectedDate)
//    }
//    
//    private func updateTotalStepsLabel() {
//        let totalSteps = dates.reduce(0) { $0 + (stepData[$1]?.0 ?? 0) }
//        totalStepsLabel.text = "총 걸음 수: \(totalSteps)"
//    }
//    
//    @objc private func showMonthSelectionModal() {
//        let monthSelectionVC = MonthSelectionViewController()
//        monthSelectionVC.delegate = self
//        monthSelectionVC.selectedDate = selectedDate
//        monthSelectionVC.modalPresentationStyle = .custom
//        monthSelectionVC.transitioningDelegate = self
//        
//        present(monthSelectionVC, animated: true, completion: nil)
//    }
//    
//    // MARK: - Planet
//    private func fetchPlanets() {
//        guard let url = URL(string: "\(backendURL)/get-all-planet") else { return }
//        
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error fetching planets: \(error)")
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//            
//            do {
//                // JSON 디코딩
//                let decoder = JSONDecoder()
//                let planets = try decoder.decode([Planet].self, from: data)
//                
//                DispatchQueue.main.async {
//                    self.planets = planets
//                    self.planetCollectionView.reloadData()
//                }
////                DispatchQueue.main.async {
////                    // planets 배열 업데이트
////                    self.planets = planets
////                    print("planets collectionView: ", planets)
////                    // 컬렉션 뷰 리로드
////                }
//            } catch {
//                print("Error decoding planets: \(error)")
//            }
//        }
//        
//        task.resume()
//    }
//}
//
//extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // MARK: - CalendarPlanetCell & CalendarDayCell
//        if collectionView == self.planetCollectionView {
//            return planets.count // Ensure this returns the correct count
//        } else {
//            return dates.count
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == self.calendarCollectionView {
//            // MARK: - CalendarDayCell
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
//            let date = dates[indexPath.item]
//         
//            // stepData에서 값을 가져올 때 튜플의 첫 번째 값인 Int만 사용
//            let steps = stepData[date]?.0 ?? 0  // steps.0으로 Int 값만 가져옴
//            
//            cell.configure(date: date, steps: steps)
//            return cell
//        } else if collectionView == self.planetCollectionView {
//            // MARK: - CalendarPlanetCell
//            guard indexPath.item < planets.count else {
//                fatalError("\(indexPath.item) 행성 배열의 경우 범위를 벗어난 인덱스입니다.")
//            }
//            let planet = planets[indexPath.item]
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarPlanetCell", for: indexPath) as! CalendarPlanetCell
//            cell.configure(planet: planet.name)
//            return cell
//        }
//        fatalError("예상치 못한 컬렉션 보기")
//    }
//
//    // MARK: CalendarCollectionView
//    func calendarCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedDate = dates[indexPath.item]
//        navigateToDetailPage(for: selectedDate)
//    }
//    
//    private func navigateToDetailPage(for date: Date) {
//        let detailVC = StepDetailViewController()
//        let stepDataForSelectedDate = stepData[date] ?? (0, "")
//        detailVC.date = date
//        detailVC.steps = stepDataForSelectedDate.0
//        detailVC.dayDestination = stepDataForSelectedDate.1
//        detailVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
//    
//    // MARK: PlanetCollectionView
//    func planetCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return planets.count
//    }
//    
//    func planetCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarPlanetCell", for: indexPath) as! CalendarPlanetCell
//        let planet = planets[indexPath.item]
//        cell.configure(planet: planet.name) // 'with:'를 'planet:'으로 수정
//        return cell
//    }
//    
//    func planetCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedPlanet = planets[indexPath.item]
//        print("Selected planet: \(selectedPlanet)")
//    }
//}
//
//extension CalendarViewController: MonthSelectionViewControllerDelegate {
//    func didSelectDate(_ date: Date) {
//        self.selectedDate = date
//        updateMonthLabel()
//        updateTotalStepsLabel()
//    }
//}
