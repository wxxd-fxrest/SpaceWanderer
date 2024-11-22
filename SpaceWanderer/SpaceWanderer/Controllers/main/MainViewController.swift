//
//  MainViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//

import UIKit
import CoreMotion
import UserNotifications

class MainViewController: UIViewController {
    var userUniqueId: String?
    var userIdentifier: String?
    var totalGoals: String? 
    
    // CMPedometer 인스턴스
    let pedometer = CMPedometer()
    
    // 누적 걸음 수
    var totalStepsToday: Double = 0.0
    
    // 실시간 걸음 수
    var realTimeSteps: Double = 0.0
    
    // 원형 프로그레스 바
    var progressLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    var progressImageView: UIImageView!
    var progressBackgroundView: UIView!
    var marsImageView: UIImageView!
    
    // 걸음 수
    var stepLabel: UILabel!
    var goalLabel: UILabel!
    var goDetailButton: UIButton!
    
    // 목적지
    var selectDestinationButton: UIButton!
    var destinationLabel: UILabel!
    var destination: String?

    // 로딩 인디케이터
    var loadingIndicator: UIActivityIndicatorView!
    
    lazy var backendURL: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["DAYSTEP_BASE_URL"] as? String {
            print("DAYSTEP_BASE_URL", backendURL)

            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.PupleColor
        print("MainViewController userIdentifier: ", userIdentifier)
        print("MainViewController totalGoals: ", totalGoals)
        addStars()
        addPlanets()
        
        // 로딩 인디케이터 초기화
        setupLoadingIndicator()
        
        // 자정부터 현재 시점까지의 걸음 수 가져오기
        fetchTotalStepsForToday()
        
        // 실시간 걸음 수 업데이트 시작
        startRealTimeStepUpdates()
        
        // 원형 프로그레스 바 초기화
        setupCircularProgressBar()
        addMarsImage()
        
        // 목적지 선택 버튼 및 라벨 초기화
        setDestinationUI()
        
        // NotificationCenter에 observer 등록
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .planetUpdatedMain, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        // 유저 데이터 가져오기
        fetchUserData()
    }
    
    @objc func updateData() {
        // 데이터를 다시 가져오는 로직 또는 UI 업데이트 로직
        fetchUserData() // 예: 행성 목록을 다시 가져옴
        print("재 업데이트")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .planetUpdatedMain, object: nil)
    }
    
    func updateStepLabel() {
        // 총 걸음 수를 String으로 변환하여 stepLabel에 할당
        stepLabel.text = String(Int(totalStepsToday + realTimeSteps))
        
        let totalSteps = self.totalStepsToday + self.realTimeSteps
        print("totalSteps: ", totalSteps)
        // 12,000보 이상이면 목표 달성 알림
        if totalSteps >= 80 {
            // 목표 달성 푸시 알림 보내기
            // goalLabel 초기화 및 설정
            goalLabel = UILabel()
            goalLabel.text = "축하합니다! 오늘 10,000걸음 목표를 달성하셨습니다!"
            goalLabel.textAlignment = .center
            goalLabel.textColor = .red // 텍스트 색상 설정
            view.addSubview(goalLabel)
            
            // selectDestinationButton 초기화 및 설정
            selectDestinationButton = UIButton()
            selectDestinationButton.setTitle(">", for: .normal)
            selectDestinationButton.tintColor = .red // 텍스트 색상 설정
            selectDestinationButton.addTarget(self, action: #selector(navigateToDetailPage), for: .touchUpInside)
            view.addSubview(selectDestinationButton)
            
            goalLabel.translatesAutoresizingMaskIntoConstraints = false
            selectDestinationButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                goalLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
                goalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                selectDestinationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
                selectDestinationButton.leadingAnchor.constraint(equalTo: goalLabel.trailingAnchor, constant: 6),
                selectDestinationButton.heightAnchor.constraint(equalToConstant: 30),
                selectDestinationButton.widthAnchor.constraint(equalToConstant: 24)
            ])
        }
    }
    
    @objc private func navigateToDestinationSelection() {
//        let destinationVC = SolarSystemViewController()
        let destinationVC = DestinationSelectionViewController()
        destinationVC.userIdentifier = userIdentifier // userIdentifier 전달
        destinationVC.totalGoals = totalGoals
        destinationVC.hidesBottomBarWhenPushed = true // 탭 바 숨기기
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @objc private func navigateToDetailPage() {
        let detailVC = StepDetailViewController()
        
        // 오늘 날짜 전달
        detailVC.date = Date()
        
        // 오늘의 총 걸음 수 전달
        let totalStepsToday = self.totalStepsToday + self.realTimeSteps
        detailVC.steps = Int(totalStepsToday)
        
        // 오늘 목표 행성 전달
        detailVC.dayDestination = destination
        
        // 탭 바 숨기기
        detailVC.hidesBottomBarWhenPushed = true
        
        // 화면 전환
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = view.center
        loadingIndicator.color = .orange
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
    private func fetchUserData() {
        let userManager = UserManager()

        guard let userIdentifier = userIdentifier else {
            print("userIdentifier가 nil입니다.")
            return
        }
                
        // 로딩 인디케이터 시작 (메인 스레드에서 실행)
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        
        userManager.getUser(by: userIdentifier) { result in
            DispatchQueue.main.async {
                // 로딩 인디케이터 중지
                self.loadingIndicator.stopAnimating()
            }
            
            switch result {
            case .success(let userEntity):
                DispatchQueue.main.async {
                    // 사용자 정보를 UI에 업데이트
                    print("사용자 ID: \(userEntity.userIdentifier)")
                    print("userEntity:", userEntity)
                    // 목적지 업데이트
                    self.destination = userEntity.destinationPlanet ?? "정보 없음"
                    self.destinationLabel.text = self.destination
                    
                    // 사용자 고유 ID 및 마지막 기록된 날짜 가져오기
                    self.fetchLastRecordedDate()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    // 오류 처리 (예: 경고 창 표시)
                    print("사용자 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 마지막 기록된 날짜를 가져와서 누락된 날짜들을 처리하고, 마지막 날짜가 이미 저장된 경우 업데이트
    func fetchLastRecordedDate() {
        guard let userUniqueId = userUniqueId else { return }
        
        let url = URL(string: "\(backendURL)/last-recorded-date/\(userUniqueId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                print("마지막 기록된 날짜를 가져오는 중 오류 발생")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let lastStepResponse = try decoder.decode(StepResponse.self, from: data)
                let lastRecordedDate = lastStepResponse.walkingDate ?? self.getTodayDate()  // nil일 경우 오늘 날짜로 설정
                print("마지막 날짜: ", lastRecordedDate)
                
                // 마지막 기록된 날짜가 없으면 (최신 회원) 오늘 날짜만 업데이트
                if lastRecordedDate.isEmpty {
                    print("마지막 기록된 날짜가 없으면 (최신 회원) 오늘 날짜만 업데이트")
                    // 오늘 날짜만 업데이트
                    self.fetchAndSendSteps(forDate: self.getTodayDate())
                } else {
                    print("마지막 기록된 날짜가 존재하면, 그 이후 날짜만 처리")
                    
                    // 마지막 기록된 날짜가 오늘 날짜가 아니라면, 누락된 날짜들을 처리
                    self.handleMissingDates(lastRecordedDate: lastRecordedDate)
                    print("마지막 기록된 날짜가 오늘 날짜가 아니라면, 누락된 날짜들을 처리")
                }
            } catch {
                print("데이터 파싱 오류: \(error)")
                // 파싱 오류가 발생했을 때 기본적으로 오늘 날짜만 업데이트
                self.fetchAndSendSteps(forDate: self.getTodayDate())
            }
        }
        task.resume()
    }

    func handleMissingDates(lastRecordedDate: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let todayDate = dateFormatter.string(from: Date())
        var currentDate = lastRecordedDate
        
        while currentDate != todayDate {
            fetchAndSendSteps(forDate: currentDate)
            
            if let date = dateFormatter.date(from: currentDate) {
                let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
                currentDate = dateFormatter.string(from: nextDate)
            }
        }
        
        if currentDate == todayDate {
            fetchAndSendSteps(forDate: currentDate)
        }
    }
    
    func getTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    // 특정 날짜에 대한 걸음 수를 가져와서 서버에 전송 또는 업데이트
    func fetchAndSendSteps(forDate date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let targetDate = dateFormatter.date(from: date) else {
            print("날짜 변환 오류: \(date)")
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: targetDate)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        
        pedometer.queryPedometerData(from: startOfDay, to: endOfDay) { data, error in
            guard error == nil, let data = data else {
                print("걸음 수 데이터를 가져오는 중 오류 발생")
                return
            }

            let deviceSteps = data.numberOfSteps.doubleValue
            self.sendStepsToServer(steps: deviceSteps, date: date)
        }
    }
    
    // 걸음 수 데이터를 서버에 전송 (새로 기록)
    func sendStepsToServer(steps: Double, date: String) {
        guard let userUniqueId = userUniqueId else { return }
        guard let destination = destination else { return } // UILabel의 text를 가져옴

        let url = URL(string: "\(backendURL)/day-walking")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // 새로운 데이터 전송

        let stepRequest = StepRequest(userUniqueId: userUniqueId, walkingDate: date, daySteps: steps, dayDestination: destination)
        print("stepRequest: ", stepRequest)
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(stepRequest)
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("서버로 데이터 전송 중 오류 발생: \(error)")
                    return
                }

                print("걸음 수 데이터가 서버에 성공적으로 전송되었습니다.")
            }
            task.resume()
        } catch {
            print("JSON 인코딩 오류: \(error)")
        }
    }
    
    // 자정부터 현재 시점까지의 걸음 수 가져오기
    func fetchTotalStepsForToday() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("걸음 수 계산을 사용할 수 없습니다.")
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
 
        pedometer.queryPedometerData(from: startOfDay, to: now) { data, error in
            guard error == nil, let data = data else {
                print("걸음 수를 가져오는 중 오류가 발생했습니다: \(String(describing: error))")
                return
            }

            self.totalStepsToday = data.numberOfSteps.doubleValue
            DispatchQueue.main.async {
                print("오늘 걸음 수(자정부터): \(self.totalStepsToday)")
                self.checkForStepGoal()
                self.updateCircularProgressBar()
            }
        }
    }
    
    // 실시간 걸음 수 업데이트
    func startRealTimeStepUpdates() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("걸음 수 계산을 사용할 수 없습니다.")
            return
        }
        
        pedometer.startUpdates(from: Date()) { data, error in
            guard error == nil, let data = data else {
                print("실시간 단계 업데이트 오류: \(String(describing: error))")
                return
            }
            
            self.realTimeSteps = data.numberOfSteps.doubleValue
            DispatchQueue.main.async {
                print("실시간 걸음 수: \(self.realTimeSteps)")
                self.checkForStepGoal()
                self.updateCircularProgressBar()
            }
        }
    }
    
    // 누적 걸음 수 + 실시간 걸음 수 합산 후 푸시 알림 전송
    func checkForStepGoal() {
        let totalSteps = self.totalStepsToday + self.realTimeSteps
        print("totalSteps: ", totalSteps)
        
        // 오늘 날짜를 UserDefaults에 저장된 날짜와 비교
        let lastNotificationDate = UserDefaults.standard.object(forKey: "lastNotificationDate") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let currentDate = Date()

        // 신규 유저 또는 첫 실행일 때, 초기값 설정
        if UserDefaults.standard.object(forKey: "notificationSentFor8k") == nil {
            UserDefaults.standard.set(false, forKey: "notificationSentFor8k")
        }
        if UserDefaults.standard.object(forKey: "notificationSentFor10k") == nil {
            UserDefaults.standard.set(false, forKey: "notificationSentFor10k")
        }

        // 날짜가 다르면 알림 상태를 리셋
        if !calendar.isDate(lastNotificationDate, inSameDayAs: currentDate) {
            UserDefaults.standard.set(false, forKey: "notificationSentFor8k")
            UserDefaults.standard.set(false, forKey: "notificationSentFor10k")
            UserDefaults.standard.set(currentDate, forKey: "lastNotificationDate")
        }

        // 8,000보 이상이면 응원 알림
        if totalSteps >= 70, !UserDefaults.standard.bool(forKey: "notificationSentFor8k") {
            // 팔천보 응원 푸시 알림 보내기
            schedulePushNotification(message: "대단해요! 이제 조금만 더 가면 목표 달성입니다!")
            
            // 알림을 보냈다고 UserDefaults에 기록
            UserDefaults.standard.set(true, forKey: "notificationSentFor8k")
        }
        
        // 12,000보 이상이면 목표 달성 알림
        if totalSteps >= 80, !UserDefaults.standard.bool(forKey: "notificationSentFor10k") {
            // 목표 달성 푸시 알림 보내기
            schedulePushNotification(message: "축하합니다! 오늘 10,000걸음 목표를 달성하셨습니다!")
            
            // 알림을 보냈다고 UserDefaults에 기록
            UserDefaults.standard.set(true, forKey: "notificationSentFor10k")
        }
    }

    func schedulePushNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "왹져의 여행"
        content.body = message
        content.sound = .default

        // 고유한 identifier 생성 (현재 시간 기반)
        let uniqueIdentifier = "stepGoalNotification_\(UUID().uuidString)"

        // 알림을 즉시 보냄
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 알림 요청 생성
        let request = UNNotificationRequest(identifier: uniqueIdentifier, content: content, trigger: trigger)

        // 알림을 등록
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("푸시 알림이 성공적으로 전송되었습니다. [\(uniqueIdentifier)]")
            }
        }
    }
    
    // 원형 프로그레스 바 설정
    func setupCircularProgressBar() {
        let radius = CGFloat(150)
        let lineWidth: CGFloat = 16
        let center = view.center
        
        trackLayer = CAShapeLayer()
        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, clockwise: true)
        trackLayer.path = trackPath.cgPath
        trackLayer.strokeColor = SpecialColors.GearGray.cgColor.copy(alpha: 0.6)
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        view.layer.addSublayer(trackLayer)
        
        progressLayer = CAShapeLayer()
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: true)
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = SpecialColors.GreenStarColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        view.layer.addSublayer(progressLayer)
    }
    
    // 원형 프로그레스 바 업데이트
    func updateCircularProgressBar() {
        // 누적 걸음 수와 실시간 걸음 수를 합산
        let totalSteps = totalStepsToday + realTimeSteps
        let maxStepCount = 1000.0
        let progress = totalSteps / maxStepCount
        
        // 배경 원형 뷰의 크기를 상수로 정의
        let backgroundDiameter: CGFloat = 34

        // 흰색 배경 원형 뷰가 없으면 생성
        if progressBackgroundView == nil {
            // 배경 원 생성
            progressBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: backgroundDiameter, height: backgroundDiameter))
            progressBackgroundView.backgroundColor = SpecialColors.GreenStarColor
            progressBackgroundView.layer.cornerRadius = backgroundDiameter / 2
            view.addSubview(progressBackgroundView)

            // 안쪽 원의 크기 계산
            let innerDiameter = backgroundDiameter - 6 // 3px 여유 공간을 양쪽에 두기 위해 6px 감소
            let innerCircleView = UIView(frame: CGRect(x: 3, y: 3, width: innerDiameter, height: innerDiameter)) // 3px 여유 공간을 두기 위해 x, y에 3px 추가
            innerCircleView.backgroundColor = SpecialColors.WhiteColor // 원하는 색상으로 설정
            innerCircleView.layer.cornerRadius = innerDiameter / 2
            progressBackgroundView.addSubview(innerCircleView)
        }
        
        // 진행 경로 계산
        let endAngle = 2 * CGFloat.pi * CGFloat(progress) - CGFloat.pi / 2
        let progressPath = UIBezierPath(arcCenter: view.center, radius: 150, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)

        // 애니메이션 설정
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = progressPath.cgPath
        animation.duration = 0.5
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        progressLayer.add(animation, forKey: "path")
        progressLayer.path = progressPath.cgPath
        
        // 진행 비율 텍스트 계산
        let progressPercentage = Int(progress * 100)
        
        // 끝 지점에 이미지 추가
//        if progressImageView == nil {
//            let progressImage = UIImage(named: "spaceProgress") // 원하는 이미지 이름
//            progressImageView = UIImageView(image: progressImage)
//            progressImageView.contentMode = .scaleAspectFit
//            let imageSize: CGFloat = 45
//            progressImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
//            progressBackgroundView.addSubview(progressImageView)
//            progressImageView.center = CGPoint(x: backgroundDiameter / 2, y: backgroundDiameter / 2) // 이미지 중앙 배치
//        }
        
        // 위치 설정 - 진행 경로의 끝 지점에 맞게 설정
        let labelRadius: CGFloat = 150
        let x = view.center.x + labelRadius * cos(endAngle)
        let y = view.center.y + labelRadius * sin(endAngle)
        
        // 흰색 배경 뷰 위치 업데이트
        progressBackgroundView.center = CGPoint(x: x, y: y)
        
        // 초기 텍스트 설정
        updateStepLabel()
    }
    
    func addStars() {
        let starCount = 100
        // 세 가지 색상 정의
        let colors: [UIColor] = [
            SpecialColors.PinkStarColor,      // 첫 번째 색상
            SpecialColors.BlueStarColor,      // 두 번째 색상
            SpecialColors.GreenStarColor,     // 세 번째 색상
            SpecialColors.WhiteStarColor      // 네 번째 색상
        ]
        
        for _ in 0..<starCount {
            let starSize: CGFloat = CGFloat.random(in: 1...6)
            let star = UIView(frame: CGRect(x: CGFloat.random(in: 0...view.bounds.width),
                                            y: CGFloat.random(in: 0...view.bounds.height),
                                            width: starSize,
                                            height: starSize))
            // 랜덤 색상 선택
            star.backgroundColor = colors.randomElement() // 배열에서 랜덤 색상 선택
            star.layer.cornerRadius = starSize / 2
            view.addSubview(star)
        }
    }

    func addPlanets() {
        let planetCount = 5
        for i in 0..<planetCount {
            let planetSize: CGFloat = CGFloat.random(in: 30...70)
            let planet = UIImageView(frame: CGRect(x: CGFloat.random(in: 0...view.bounds.width),
                                                   y: CGFloat.random(in: 0...view.bounds.height),
                                                   width: planetSize,
                                                   height: planetSize))
            planet.image = UIImage(named: "planet\(i + 1)")
            planet.contentMode = .scaleAspectFit
            
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.values = [
                CGPoint(x: planet.center.x, y: planet.center.y),
                CGPoint(x: planet.center.x + CGFloat.random(in: -10...10), y: planet.center.y + CGFloat.random(in: -10...10))
            ]
            animation.keyTimes = [0, 1]
            animation.duration = 2
            animation.autoreverses = true
            animation.repeatCount = .infinity
            
            planet.layer.add(animation, forKey: "floating")
            view.addSubview(planet)
        }
    }
    
    // 화성 이미지 추가
    func addMarsImage() {
        let marsImage = UIImage(named: "spaceship") // "mars"는 화성 이미지 파일 이름
        marsImageView = UIImageView(image: marsImage)
        marsImageView.frame = CGRect(x: view.center.x - 90, y: view.center.y - 90, width: 180, height: 180)
        marsImageView.contentMode = .scaleAspectFit
        view.addSubview(marsImageView)
    }
    
    func setDestinationUI() {
        // stepLabel 초기화 및 설정
        stepLabel = UILabel()
        stepLabel.textAlignment = .center
        stepLabel.frame = CGRect(x: (view.frame.width - 200) / 2, y: (view.frame.height - 80) / 2, width: 200, height: 50) // 가로 200, 세로 50
        stepLabel.textColor = .blue // 텍스트 색상 설정
        view.addSubview(stepLabel)
        
        // selectDestinationButton 초기화 및 설정
        selectDestinationButton = UIButton()
        selectDestinationButton.setTitle("목적지 선택", for: .normal)
        selectDestinationButton.frame = CGRect(x: (view.frame.width - 120) / 2, y: 40, width: 200, height: 50) // 가로 200, 세로 50
        selectDestinationButton.tintColor = .blue // 텍스트 색상 설정
        selectDestinationButton.addTarget(self, action: #selector(navigateToDestinationSelection), for: .touchUpInside)
        view.addSubview(selectDestinationButton)
        
        // destinationLabel 초기화 및 설정
        destinationLabel = UILabel()
        destinationLabel.textAlignment = .center
        destinationLabel.frame = CGRect(x: (view.frame.width - 300) / 2, y: 40, width: 200, height: 50) // 가로 200, 세로 50
        destinationLabel.textColor = .blue // 텍스트 색상 설정
        view.addSubview(destinationLabel)
    }
}
