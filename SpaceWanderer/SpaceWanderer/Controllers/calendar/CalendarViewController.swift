//
//  CalendarViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/5/24.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?

    private let calendar = Calendar.current
    private var dates = [Date]() // 달력에 표시할 날짜 목록
    private var stepData: [Date: Int] = [:] // 날짜별 걸음 수 데이터
    private var selectedDate = Date()
    
    private lazy var collectionView: UICollectionView = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        setupViews()
        setupDates()
        updateMonthLabel()
        updateTotalStepsLabel()
                
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        
        guard let userUniqueId = userUniqueId else {
            print("User Unique ID is missing.")
            return
        }
        
        fetchStepData(for: userUniqueId, year: year, month: month)
        
        // 년월 표시 클릭 이벤트
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMonthSelectionModal))
        monthLabel.addGestureRecognizer(tapGesture)
    }

    private func setupViews() {
        view.addSubview(monthLabel)
        view.addSubview(totalStepsLabel)
        view.addSubview(collectionView)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        totalStepsLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            totalStepsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            totalStepsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
                    self.collectionView.reloadData()
                }
            } catch {
                print("Error decoding step data: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    // JSON을 StepEntity 객체로 변환
    private func convertStepEntitiesToDictionary(_ stepEntities: [StepRequest]) -> [Date: Int] {
        var stepData: [Date: Int] = [:]
        
        for entity in stepEntities {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let dateObj = formatter.date(from: entity.walkingDate) {
                // daySteps를 Int로 변환하여 저장
                stepData[dateObj] = Int(entity.daySteps)
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
        let totalSteps = dates.reduce(0) { $0 + (stepData[$1] ?? 0) }
        totalStepsLabel.text = "총 걸음 수: \(totalSteps)"
    }
    
    @objc private func showMonthSelectionModal() {
        let monthSelectionVC = MonthSelectionViewController()
        monthSelectionVC.delegate = self
        monthSelectionVC.selectedDate = selectedDate
        monthSelectionVC.modalPresentationStyle = .custom
        monthSelectionVC.transitioningDelegate = self // 바텀 시트 표시를 위해 필요
        
        present(monthSelectionVC, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        let date = dates[indexPath.item]
        let steps = stepData[date] ?? 0
        cell.configure(date: date, steps: steps)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 16) / 7 // 7일이 일주일
        return CGSize(width: width, height: width)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = dates[indexPath.item]
        navigateToDetailPage(for: selectedDate)
    }
    
    private func navigateToDetailPage(for date: Date) {
        let detailVC = StepDetailViewController()
        detailVC.date = date
        detailVC.steps = stepData[date] ?? 0
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
