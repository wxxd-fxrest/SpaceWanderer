//
//  CalendarViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/5/24.
//

//import UIKit
//
//class CalendarViewController: UIViewController, UIPopoverPresentationControllerDelegate {
//    var userUniqueId: String?
//    var userIdentifier: String?
//    var totalGoals: String?
//
//    // MARK: - 캘린더 컬렉션
//    let calendar = Calendar.current
//    var dates = [Date]() // 달력에 표시할 날짜 목록
//    var stepData: [Date: (Int, String)] = [:] // 날짜별 걸음 수와 행성 정보 데이터
//    var selectedDate = Date()
//    
//    // MARK: - 행성 컬렉션
//    var planets: [Planet] = []
//    
//    // MARK: - UI
//    var calendarView: CalendarView! // CalendarView 인스턴스
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = SpecialColors.MainViewBackGroundColor
//        setupCalendarView()
//        setupDates()
//        updateMonthLabel()
//        updateTotalStepsLabel()
//        updatePlanetLabel()
//        
//        calendarView.calendarCollectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
//        calendarView.planetCollectionView.register(CalendarPlanetCell.self, forCellWithReuseIdentifier: "CalendarPlanetCell")
//
//        // 선택된 날짜의 연도와 월을 가져옴
//        let year = calendar.component(.year, from: selectedDate)
//        let month = calendar.component(.month, from: selectedDate)
//        
//        fetchPlanets()
//        
//        // 년월 표시 클릭 이벤트
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMonthSelectionModal))
//        calendarView.monthLabel.addGestureRecognizer(tapGesture)
//        
//        print("CalendarViewController totalGoals: ", totalGoals)
//        
//        // NotificationCenter에 observer 등록
//        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .planetUpdatedCalendar, object: nil)
//    }
//    
//    @objc func updateData() {
//        guard let userUniqueId = userUniqueId else {
//            print("User Unique ID is missing.")
//            return
//        }
//        let year = calendar.component(.year, from: selectedDate)
//        let month = calendar.component(.month, from: selectedDate)
//        print("Calling fetchStepData with userUniqueId:", userUniqueId, "year:", year, "month:", month)
//        fetchStepData(for: userUniqueId, year: year, month: month)
//    }
//    
//    func updateMonthLabel() {
//        calendarView.updateMonthLabel(with: selectedDate) // selectedDate를 인자로 전달
//    }
//
//    func updateTotalStepsLabel() {
//        let totalSteps = stepData.values.reduce(0) { $0 + $1.0 }
//        calendarView.updateTotalStepsLabel(with: totalSteps) // 총 걸음 수를 인자로 전달
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: .planetUpdatedCalendar, object: nil)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        
//        guard let userUniqueId = userUniqueId else {
//            print("User Unique ID is missing.")
//            return
//        }
//        let year = calendar.component(.year, from: selectedDate)
//        let month = calendar.component(.month, from: selectedDate)
//        print("Calling fetchStepData with userUniqueId:", userUniqueId, "year:", year, "month:", month)
//        fetchStepData(for: userUniqueId, year: year, month: month)
//    }
//
//     func setupCalendarView() {
//        calendarView = CalendarView() // CalendarView 인스턴스 생성
//        view.addSubview(calendarView)
//        calendarView.frame = view.bounds
//        calendarView.calendarCollectionView.dataSource = self
//        calendarView.calendarCollectionView.delegate = self
//        calendarView.planetCollectionView.dataSource = self
//        calendarView.planetCollectionView.delegate = self
//    }
//    
//    func setupDates() {
//        // 이번 달의 날짜들을 계산해서 dates 배열에 추가
//        let components = calendar.dateComponents([.year, .month], from: selectedDate)
//        guard let startOfMonth = calendar.date(from: components) else { return }
//        
//        dates.removeAll()
//        for day in 0..<calendar.range(of: .day, in: .month, for: startOfMonth)!.count {
//            if let date = calendar.date(byAdding: .day, value: day, to: startOfMonth) {
//                dates.append(date)
//            }
//        }
//    }
//    
//    // MARK: - Calendar
//    // MARK: GET: 한달 간격의 캘린더 데이터 가져오기
//    func fetchStepData(for userUniqueId: String, year: Int, month: Int) {
//        UserAPIManager.shared.fetchMonthStepData(for: userUniqueId, year: year, month: month) {
//            result in
//            switch result {
//            case .success(let stepData):
//                DispatchQueue.main.async {
//                    self.stepData = self.convertStepEntitiesToDictionary(stepData)
//                    print("Updated stepData: \(self.stepData)")
//                    let totalSteps = self.stepData.values.reduce(0) { $0 + $1.0 }
//                    self.calendarView.updateTotalStepsLabel(with: totalSteps)
//                    self.calendarView.calendarCollectionView.reloadData()
//                }
//                
//            case .failure(let error):
//                print("Error fetching step data: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    // JSON을 StepEntity 객체로 변환
//    private func convertStepEntitiesToDictionary(_ stepEntities: [StepRequest]) -> [Date: (Int, String)] {
//        var stepData: [Date: (Int, String)] = [:]
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
//        
//        for entity in stepEntities {
//            if let utcDate = formatter.date(from: entity.walkingDate) {
//                let localDate = Calendar.current.startOfDay(for: utcDate)
//                
//                let steps = Int(entity.daySteps)
//                guard steps > 0 else { continue }
//                
//                if let existingData = stepData[localDate] {
//                    let existingSteps = existingData.0
//                    stepData[localDate] = (existingSteps + steps, entity.dayDestination)
//                } else {
//                    stepData[localDate] = (steps, entity.dayDestination)
//                }
//            }
//        }
//        return stepData
//    }
//    
//    private func updatePlanetLabel() {
//        calendarView.updatePlanetLabel(with: "Planet")
//    }
//    
//    @objc private func showMonthSelectionModal() {
//        let monthSelectionVC = MonthSelectionViewController()
//        monthSelectionVC.delegate = self
//        monthSelectionVC.selectedDate = selectedDate
//        monthSelectionVC.modalPresentationStyle = .custom
//        monthSelectionVC.transitioningDelegate = self // 바텀 시트 표시를 위해 필요
//        
//        present(monthSelectionVC, animated: true, completion: nil)
//    }
//
//    // MARK: - Planet
//    private func fetchPlanets() {
//        PlanetAPIManager.shared.fetchPlanets { result in
//            switch result {
//            case .success(let planets):
//                DispatchQueue.main.async {
//                    self.planets = planets
//                    self.calendarView.planetCollectionView.reloadData()
//                }
//                
//            case .failure(let error):
//                print("Error fetching planets: \(error.localizedDescription)")
//            }
//        }
//    }
//}



import UIKit

class CalendarViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    var userUniqueId: String?
    var userIdentifier: String?
    var totalGoals: String?

    // MARK: - 캘린더 컬렉션
    let calendar = Calendar.current
    var dates = [Date]() // 달력에 표시할 날짜 목록
    var stepData: [Date: (Int, String)] = [:] // 날짜별 걸음 수와 행성 정보 데이터
    var selectedDate = Date()
    
    // MARK: - 행성 컬렉션
    var planets: [Planet] = []
    
    // MARK: - UI
    var calendarView: CalendarView! // CalendarView 인스턴스
    let viewModel = CalendarViewModel() // ViewModel 인스턴스

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        setupCalendarView()
        setupDates()
        updateMonthLabel()
        updateTotalStepsLabel()
        updatePlanetLabel()
        
        calendarView.calendarCollectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        calendarView.planetCollectionView.register(CalendarPlanetCell.self, forCellWithReuseIdentifier: "CalendarPlanetCell")

        // 선택된 날짜의 연도와 월을 가져옴
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        
        fetchPlanets()
        
        // 년월 표시 클릭 이벤트
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMonthSelectionModal))
        calendarView.monthLabel.addGestureRecognizer(tapGesture)
        
        print("CalendarViewController totalGoals: ", totalGoals)
        
        // NotificationCenter에 observer 등록
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .planetUpdatedCalendar, object: nil)
    }
    
    // ViewModel을 사용하여 데이터 가져오기
    func fetchStepData(for userUniqueId: String, year: Int, month: Int) {
        viewModel.fetchStepData(for: userUniqueId, year: year, month: month) { result in
            switch result {
            case .success(let stepData):
                DispatchQueue.main.async {
                    self.stepData = stepData
                    self.updateTotalStepsLabel()
                    self.calendarView.calendarCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching step data: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func updateData() {
        guard let userUniqueId = userUniqueId else {
            print("User Unique ID is missing.")
            return
        }
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        print("Calling fetchStepData with userUniqueId:", userUniqueId, "year:", year, "month:", month)
        fetchStepData(for: userUniqueId, year: year, month: month)
    }
    
    func updateMonthLabel() {
        calendarView.updateMonthLabel(with: selectedDate) // selectedDate를 인자로 전달
    }

    func updateTotalStepsLabel() {
        let totalSteps = stepData.values.reduce(0) { $0 + $1.0 }
        calendarView.updateTotalStepsLabel(with: totalSteps) // 총 걸음 수를 인자로 전달
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .planetUpdatedCalendar, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        guard let userUniqueId = userUniqueId else {
            print("User Unique ID is missing.")
            return
        }
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        print("Calling fetchStepData with userUniqueId:", userUniqueId, "year:", year, "month:", month)
        fetchStepData(for: userUniqueId, year: year, month: month)
    }
    
    func setupDates() {
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

    // MARK: - Planet
    func fetchPlanets() {
        // ViewModel을 사용하여 행성 데이터 가져오기
        viewModel.fetchPlanets { result in
            switch result {
            case .success(let planets):
                DispatchQueue.main.async {
                    self.planets = planets
                    self.calendarView.planetCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching planets: \(error.localizedDescription)")
            }
        }
    }

     func setupCalendarView() {
        calendarView = CalendarView() // CalendarView 인스턴스 생성
        view.addSubview(calendarView)
        calendarView.frame = view.bounds
        calendarView.calendarCollectionView.dataSource = self
        calendarView.calendarCollectionView.delegate = self
        calendarView.planetCollectionView.dataSource = self
        calendarView.planetCollectionView.delegate = self
    }
    
    private func updatePlanetLabel() {
        calendarView.updatePlanetLabel(with: "Planet")
    }
    
    @objc private func showMonthSelectionModal() {
        let monthSelectionVC = MonthSelectionViewController()
        monthSelectionVC.delegate = self
        monthSelectionVC.selectedDate = selectedDate
        monthSelectionVC.modalPresentationStyle = .custom
        monthSelectionVC.transitioningDelegate = self // 바텀 시트 표시를 위해 필요
        
        present(monthSelectionVC, animated: true, completion: nil)
    }
}
