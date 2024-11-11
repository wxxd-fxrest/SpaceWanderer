//
//  MainViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//

//import UIKit
//import CoreMotion
//import UserNotifications
//
//class MainViewController: UIViewController {
//    var userUniqueId: String?
//    var accessToken: String?
//    var userIdentifier: String?
//    
//    // CMPedometer 인스턴스
//    let pedometer = CMPedometer()
//    
//    // 누적 걸음 수
//    var totalStepsToday: Double = 0.0
//    
//    // 실시간 걸음 수
//    var realTimeSteps: Double = 0.0
//    
//    // 원형 프로그레스 바
//    var progressLayer: CAShapeLayer!
//    var trackLayer: CAShapeLayer!
//    var progressLabel: UILabel!
//    var marsImageView: UIImageView!
//    
//    var stepLabel: UILabel!
//    
//    lazy var backendURL: String = {
//        // Space.plist에서 BackendURL 가져오기
//        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
//           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
//           let backendURL = spaceDict["DAYSTEP_BASE_URL"] as? String {
//            print("DAYSTEP_BASE_URL", backendURL)
//
//            return backendURL
//        } else {
//            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
//            return "http://localhost:1020" // 기본값 설정
//        }
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.black
//        addStars()
//        addPlanets()
//        
//        // 자정부터 현재 시점까지의 걸음 수 가져오기
//        fetchTotalStepsForToday()
//        
//        // 실시간 걸음 수 업데이트 시작
//        startRealTimeStepUpdates()
//        
//        // 원형 프로그레스 바 초기화
//        setupCircularProgressBar()
//        addMarsImage()
//        
//        // stepLabel 초기화 및 설정
//        stepLabel = UILabel()
//        stepLabel.textAlignment = .center
//        stepLabel.frame = CGRect(x: (view.frame.width - 200) / 2, y: (view.frame.height - 80) / 2, width: 200, height: 50) // 가로 200, 세로 50
//        stepLabel.textColor = .blue // 텍스트 색상 설정
//        view.addSubview(stepLabel)
//    }
//    
//    func updateStepLabel() {
//        // 총 걸음 수를 String으로 변환하여 stepLabel에 할당
//        stepLabel.text = String(Int(totalStepsToday + realTimeSteps))
//    }
//    
//    // 자정부터 현재 시점까지의 걸음 수 가져오기
//    func fetchTotalStepsForToday() {
//        guard CMPedometer.isStepCountingAvailable() else {
//            print("걸음 수 계산을 사용할 수 없습니다.")
//            return
//        }
//
//        let now = Date()
//        let startOfDay = Calendar.current.startOfDay(for: now)
//
//        pedometer.queryPedometerData(from: startOfDay, to: now) { data, error in
//            guard error == nil, let data = data else {
//                print("걸음 수를 가져오는 중 오류가 발생했습니다: \(String(describing: error))")
//                return
//            }
//
//            self.totalStepsToday = data.numberOfSteps.doubleValue
//            DispatchQueue.main.async {
//                print("오늘 걸음 수(자정부터): \(self.totalStepsToday)")
//                
//                self.sendStepDataToServer { success in
//                    if success {
//                        print("데이터 전송 성공")
//                    } else {
//                        print("데이터 전송 실패")
//                    }
//                }
//                self.updateCircularProgressBar()
//            }
//        }
//    }
//    
//    // 실시간 걸음 수 업데이트
//    func startRealTimeStepUpdates() {
//        guard CMPedometer.isStepCountingAvailable() else {
//            print("걸음 수 계산을 사용할 수 없습니다.")
//            return
//        }
//        
//        pedometer.startUpdates(from: Date()) { data, error in
//            guard error == nil, let data = data else {
//                print("실시간 단계 업데이트 오류: \(String(describing: error))")
//                return
//            }
//            
//            self.realTimeSteps = data.numberOfSteps.doubleValue
//            DispatchQueue.main.async {
//                print("실시간 걸음 수: \(self.realTimeSteps)")
//                self.updateCircularProgressBar()
//            }
//        }
//    }
//
//    func sendStepDataToServer(completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: "\(backendURL)/day-walking") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // 현재 날짜를 yyyy-MM-dd 형식으로 변환
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let formattedDate = dateFormatter.string(from: Date())
//        
//        let body: [String: Any] = [
//            "userUniqueId": userUniqueId ?? "",
//            "walkingDate": formattedDate,
//            "daySteps": Int(totalStepsToday)
//        ]
//        
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error sending data: \(error)")
//                completion(false)
//                return
//            }
//            
//            if let response = response as? HTTPURLResponse {
//                if response.statusCode == 201 {
//                    print("데이터가 성공적으로 전송되었습니다!")
//                    completion(true)
//                } else {
//                    print("데이터 전송 실패, 상태 코드: \(response.statusCode)")
//                    completion(false)
//                }
//            }
//        }
//        
//        task.resume()
//    }
//
//    // 원형 프로그레스 바 설정
//    func setupCircularProgressBar() {
//        let radius = CGFloat(100)
//        let lineWidth: CGFloat = 16
//        let center = view.center
//        
//        trackLayer = CAShapeLayer()
//        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, clockwise: true)
//        trackLayer.path = trackPath.cgPath
//        trackLayer.strokeColor = UIColor.lightGray.cgColor
//        trackLayer.lineWidth = lineWidth
//        trackLayer.fillColor = UIColor.clear.cgColor
//        trackLayer.lineCap = .round
//        view.layer.addSublayer(trackLayer)
//        
//        progressLayer = CAShapeLayer()
//        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: true)
//        progressLayer.path = progressPath.cgPath
//        progressLayer.strokeColor = UIColor.blue.cgColor
//        progressLayer.lineWidth = lineWidth
//        progressLayer.fillColor = UIColor.clear.cgColor
//        progressLayer.lineCap = .round
//        view.layer.addSublayer(progressLayer)
//    }
//    
//    // 원형 프로그레스 바 업데이트
//    func updateCircularProgressBar() {
//        // 누적 걸음 수와 실시간 걸음 수를 합산
//        let totalSteps = totalStepsToday + realTimeSteps
//        let maxStepCount = 1000.0
//        let progress = totalSteps / maxStepCount
//        
//        let endAngle = 2 * CGFloat.pi * CGFloat(progress) - CGFloat.pi / 2
//        let progressPath = UIBezierPath(arcCenter: view.center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)
//        
//        let animation = CABasicAnimation(keyPath: "path")
//        animation.toValue = progressPath.cgPath
//        animation.duration = 0.5
//        animation.fillMode = .forwards
//        animation.isRemovedOnCompletion = false
//        
//        progressLayer.add(animation, forKey: "path")
//        progressLayer.path = progressPath.cgPath
//        
//        // 진행 비율 텍스트 계산
//        let progressPercentage = Int(progress * 100)
//        let labelAngle = endAngle
//        let labelRadius = CGFloat(100)
//        let x = view.center.x + labelRadius * cos(labelAngle)
//        let y = view.center.y + labelRadius * sin(labelAngle)
//        
//        // 끝 지점에 UILabel 위치 설정
//        if progressLabel == nil {
//            progressLabel = UILabel()
//            progressLabel.font = UIFont.boldSystemFont(ofSize: 18)
//            progressLabel.textColor = UIColor.white
//            progressLabel.textAlignment = .center
//            view.addSubview(progressLabel)
//        }
//        
//        progressLabel.text = "\(progressPercentage)%"
//        progressLabel.frame = CGRect(x: x - 30, y: y - 20, width: 60, height: 40)
//        
//        
//        // 초기 텍스트 설정
//        updateStepLabel()
//    }
//    
//    // 다른 UI 요소들...
//    func addStars() {
//        let starCount = 100
//        for _ in 0..<starCount {
//            let starSize: CGFloat = CGFloat.random(in: 2...5)
//            let star = UIView(frame: CGRect(x: CGFloat.random(in: 0...view.bounds.width),
//                                            y: CGFloat.random(in: 0...view.bounds.height),
//                                            width: starSize,
//                                            height: starSize))
//            star.backgroundColor = UIColor.white
//            star.layer.cornerRadius = starSize / 2
//            view.addSubview(star)
//        }
//    }
//    
//    func addPlanets() {
//        let planetCount = 5
//        for i in 0..<planetCount {
//            let planetSize: CGFloat = CGFloat.random(in: 30...70)
//            let planet = UIImageView(frame: CGRect(x: CGFloat.random(in: 0...view.bounds.width),
//                                                   y: CGFloat.random(in: 0...view.bounds.height),
//                                                   width: planetSize,
//                                                   height: planetSize))
//            planet.image = UIImage(named: "planet\(i + 1)")
//            planet.contentMode = .scaleAspectFit
//            
//            let animation = CAKeyframeAnimation(keyPath: "position")
//            animation.values = [
//                CGPoint(x: planet.center.x, y: planet.center.y),
//                CGPoint(x: planet.center.x + CGFloat.random(in: -10...10), y: planet.center.y + CGFloat.random(in: -10...10))
//            ]
//            animation.keyTimes = [0, 1]
//            animation.duration = 2
//            animation.autoreverses = true
//            animation.repeatCount = .infinity
//            
//            planet.layer.add(animation, forKey: "floating")
//            view.addSubview(planet)
//        }
//    }
//    
//    // 화성 이미지 추가
//    func addMarsImage() {
//        let marsImage = UIImage(named: "faceAlienImage") // "mars"는 화성 이미지 파일 이름
//        marsImageView = UIImageView(image: marsImage)
//        marsImageView.frame = CGRect(x: view.center.x - 60, y: view.center.y - 60, width: 120, height: 120)
//        marsImageView.contentMode = .scaleAspectFit
//        view.addSubview(marsImageView)
//    }
//}
//


import UIKit
import CoreMotion
import UserNotifications

// JSON 인코딩을 위한 StepRequest 구조체
struct StepRequest: Codable {
    var userUniqueId: String
    var walkingDate: String
    var daySteps: Double
    var dayDestination: String = "천왕성"  // 기본값을 "천왕성"으로 설정
}

// 서버 응답을 위한 StepResponse 구조체
struct StepResponse: Codable {
    var walkingDate: String
    var daySteps: Double
}

class MainViewController: UIViewController {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
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
    
    var stepLabel: UILabel!
    
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
        view.backgroundColor = SpecialColors.GearGray
        addStars()
        addPlanets()
        
        // 사용자 고유 ID 및 마지막 기록된 날짜 가져오기
        fetchLastRecordedDate()
        
        // 자정부터 현재 시점까지의 걸음 수 가져오기
        fetchTotalStepsForToday()
        
        // 실시간 걸음 수 업데이트 시작
        startRealTimeStepUpdates()
        
        // 원형 프로그레스 바 초기화
        setupCircularProgressBar()
        addMarsImage()
        
        // stepLabel 초기화 및 설정
        stepLabel = UILabel()
        stepLabel.textAlignment = .center
        stepLabel.frame = CGRect(x: (view.frame.width - 200) / 2, y: (view.frame.height - 80) / 2, width: 200, height: 50) // 가로 200, 세로 50
        stepLabel.textColor = .blue // 텍스트 색상 설정
        view.addSubview(stepLabel)
    }
    
    func updateStepLabel() {
        // 총 걸음 수를 String으로 변환하여 stepLabel에 할당
        stepLabel.text = String(Int(totalStepsToday + realTimeSteps))
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
                print("마지막 날짜: ", lastStepResponse.walkingDate)
                
                // 마지막 기록된 날짜가 없으면 (최신 회원) 오늘 날짜만 업데이트
                if lastStepResponse.walkingDate.isEmpty {
                    // 오늘 날짜만 업데이트
                    self.fetchAndSendSteps(forDate: self.getTodayDate())
                } else {
                    // 마지막 기록된 날짜가 존재하면, 그 이후 날짜만 처리
                    let lastRecordedDate = lastStepResponse.walkingDate
                    let todayDate = self.getTodayDate()
                    
                    // 만약 마지막 날짜가 오늘 날짜라면, 아무 것도 하지 않고 리턴
                    if lastRecordedDate == todayDate {
                        return
                    }
                    
                    // 마지막 기록된 날짜가 오늘 날짜가 아니라면, 누락된 날짜들을 처리
                    self.handleMissingDates(lastRecordedDate: lastRecordedDate)
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

        let url = URL(string: "\(backendURL)/day-walking")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // 새로운 데이터 전송

        let stepRequest = StepRequest(userUniqueId: userUniqueId, walkingDate: date, daySteps: steps, dayDestination: "천왕성")
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
                self.updateCircularProgressBar()
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
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        view.layer.addSublayer(trackLayer)
        
        progressLayer = CAShapeLayer()
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: true)
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = SpecialColors.GreenColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        view.layer.addSublayer(progressLayer)
    }
    
    // 원형 프로그레스 바 업데이트
    func updateCircularProgressBar() {
        // 누적 걸음 수와 실시간 걸음 수를 합산
        let totalSteps = totalStepsToday + realTimeSteps
        let maxStepCount = 10000.0
        let progress = totalSteps / maxStepCount
        
        // 배경 원형 뷰의 크기를 상수로 정의
        let backgroundDiameter: CGFloat = 60

        // 흰색 배경 원형 뷰가 없으면 생성
        if progressBackgroundView == nil {
            progressBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: backgroundDiameter, height: backgroundDiameter))
            progressBackgroundView.backgroundColor = SpecialColors.WhiteColor
            progressBackgroundView.layer.cornerRadius = backgroundDiameter / 2
            view.addSubview(progressBackgroundView)
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
        if progressImageView == nil {
            let progressImage = UIImage(named: "spaceProgress") // 원하는 이미지 이름
            progressImageView = UIImageView(image: progressImage)
            progressImageView.contentMode = .scaleAspectFit
            let imageSize: CGFloat = 45
            progressImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
            progressBackgroundView.addSubview(progressImageView)
            progressImageView.center = CGPoint(x: backgroundDiameter / 2, y: backgroundDiameter / 2) // 이미지 중앙 배치
        }
        
        // 위치 설정 - 진행 경로의 끝 지점에 맞게 설정
        let labelRadius: CGFloat = 150
        let x = view.center.x + labelRadius * cos(endAngle)
        let y = view.center.y + labelRadius * sin(endAngle)
        
        // 흰색 배경 뷰 위치 업데이트
        progressBackgroundView.center = CGPoint(x: x, y: y)
        
        // 초기 텍스트 설정
        updateStepLabel()
    }

    
    // 다른 UI 요소들...
    func addStars() {
        let starCount = 100
        for _ in 0..<starCount {
            let starSize: CGFloat = CGFloat.random(in: 2...5)
            let star = UIView(frame: CGRect(x: CGFloat.random(in: 0...view.bounds.width),
                                            y: CGFloat.random(in: 0...view.bounds.height),
                                            width: starSize,
                                            height: starSize))
            star.backgroundColor = UIColor.white
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
}
