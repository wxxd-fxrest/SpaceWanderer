//
//  MainViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//

import UIKit
import HealthKit

class MainViewController: UIViewController {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    // HealthStore instance
    let healthStore = HKHealthStore()

    // 원형 프로그레스 바
    var progressLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    
    // 진행 비율을 표시할 UILabel
    var progressLabel: UILabel!
    
    // 화성 이미지
    var marsImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MainViewController Props: ", userUniqueId, accessToken, userIdentifier)
        
        // 배경 색상 설정
        view.backgroundColor = UIColor.black
        
        // 별과 행성 추가
        addStars()
        addPlanets()
        
        // HealthKit 권한 요청 및 걸음 수 데이터 가져오기
        requestHealthKitAuthorization()
        
        // 원형 프로그레스 바 초기화
        setupCircularProgressBar()
        
        // 화성 이미지 추가
               addMarsImage()
    }

    func addStars() {
        let starCount = 100 // 별의 개수
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
        let planetCount = 5 // 행성의 개수
        for i in 0..<planetCount {
            let planetSize: CGFloat = CGFloat.random(in: 30...70)
            let planet = UIImageView(frame: CGRect(x: CGFloat.random(in: 0...view.bounds.width),
                                                    y: CGFloat.random(in: 0...view.bounds.height),
                                                    width: planetSize,
                                                    height: planetSize))
            planet.image = UIImage(named: "planet\(i + 1)") // 행성 이미지 이름에 맞게 수정
            planet.contentMode = .scaleAspectFit
            
            // 행성의 위치를 약간 애니메이션 효과 추가
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
    
    // HealthKit 권한 요청
    func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // 걸음 수 데이터 타입 정의
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        // 읽기 권한 요청
        let healthDataToRead: Set = [stepCountType]
        
        healthStore.requestAuthorization(toShare: nil, read: healthDataToRead) { success, error in
            if success {
                // 권한이 허용되었을 때 걸음 수 데이터 가져오기 시작
                self.fetchStepCount()
            } else {
                print("HealthKit 권한이 허용되지 않음: \(String(describing: error))")
            }
        }
    }
    
    // 걸음 수 데이터 가져오기
    func fetchStepCount() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        // 24시간 전부터 현재까지의 걸음 수를 가져옴
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // 합계 계산을 위한 쿼리
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("걸음 수 데이터를 가져오지 못함: \(String(describing: error))")
                return
            }
            
            // 걸음 수 데이터 가져오기
            let stepCount = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                print("오늘 걸음 수: \(stepCount)")
                
                // 원형 프로그레스 바 업데이트
                self.updateCircularProgressBar(stepCount: stepCount)
            }
        }
        
        // 쿼리 실행
        healthStore.execute(query)
    }

    //MARK: - Test Step Count
//    func fetchStepCount() {
//        let stepCount = 0.0  // 임의로 걸음 수 설정
//        DispatchQueue.main.async {
//            print("오늘 걸음 수: \(stepCount)")
//            self.updateCircularProgressBar(stepCount: stepCount)
//        }
//    }
    
    // 원형 프로그레스 바 설정
    func setupCircularProgressBar() {
        let radius = CGFloat(100)
        let lineWidth: CGFloat = 10
        let center = view.center // 원형 프로그레스 바의 중심 위치
        
        // Track Layer (배경 원)
        trackLayer = CAShapeLayer()
        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, clockwise: true)
        trackLayer.path = trackPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        view.layer.addSublayer(trackLayer)
        
        // Progress Layer (진행 원)
        progressLayer = CAShapeLayer()
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: true)
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = UIColor.blue.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        view.layer.addSublayer(progressLayer)
    }
    
    // 원형 프로그레스 바 업데이트
    func updateCircularProgressBar(stepCount: Double) {
        let maxStepCount = 10000.0
        let progress = stepCount / maxStepCount
        
        let endAngle = 2 * CGFloat.pi * CGFloat(progress) - CGFloat.pi / 2
        let progressPath = UIBezierPath(arcCenter: view.center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)
        
        // 애니메이션을 추가하여 진행 바가 부드럽게 갱신되도록 함
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = progressPath.cgPath
        animation.duration = 0.5
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        progressLayer.add(animation, forKey: "path")
        progressLayer.path = progressPath.cgPath
        
        // 진행 비율 텍스트 계산 및 끝 위치 계산
        let progressPercentage = Int(progress * 100)
        let labelAngle = endAngle // 진행 바 끝 각도
        
        // 끝 지점 계산
        let labelRadius = CGFloat(100) // 바보다 조금 더 외부에 위치하도록 설정
        let x = view.center.x + labelRadius * cos(labelAngle)
        let y = view.center.y + labelRadius * sin(labelAngle)
        
        // 끝 지점에 UILabel 위치 설정
        if progressLabel == nil {
            progressLabel = UILabel()
            progressLabel.font = UIFont.boldSystemFont(ofSize: 18)
            progressLabel.textColor = UIColor.white
            progressLabel.textAlignment = .center
            view.addSubview(progressLabel)
        }
        
        progressLabel.text = "\(progressPercentage)%"
        progressLabel.frame = CGRect(x: x - 30, y: y - 20, width: 60, height: 40)
    }
    
    
    // 화성 이미지 추가
    func addMarsImage() {
        let marsImage = UIImage(named: "faceAlienImage") // "mars"는 화성 이미지 파일 이름
        marsImageView = UIImageView(image: marsImage)
        marsImageView.frame = CGRect(x: view.center.x - 60, y: view.center.y - 60, width: 120, height: 120)
        marsImageView.contentMode = .scaleAspectFit
        view.addSubview(marsImageView)
    }
}
