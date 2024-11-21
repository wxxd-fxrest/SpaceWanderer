//
//  SolarSystemViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/22/24.
//

//import UIKit
//
//class SolarSystemViewController: UIViewController {
//
//    // 태양과 행성 이미지 뷰를 위한 변수
//    var sunImageView: UIImageView!
//    var planets: [UIImageView] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // 배경 색상 설정 (검은색으로 설정하여 우주 느낌을 낼 수 있음)
//        view.backgroundColor = .black
//        
//        // 태양 이미지 설정
//        sunImageView = UIImageView(image: UIImage(named: "태양"))
//        sunImageView.frame = CGRect(x: view.center.x - 15, y: view.center.y - 15, width: 30, height: 30)
//        sunImageView.clipsToBounds = true
//        view.addSubview(sunImageView)
//        
//        // 행성들 설정 (행성 개수만큼 추가)
//        let planetNames = ["수성", "금성", "지구", "화성", "목성", "토성", "천왕성", "해왕성"]
//        let planetRadius: [CGFloat] = [36, 55, 75, 95, 120, 140, 160, 190]  // 실제 거리 비율로 조정
//        let planetSpeeds: [Double] = [2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]  // 속도 비율 설정
//        
//        // 수성을 느리게 하고 나머지 행성들도 비례하여 속도 조정
//        let mercurySpeed: Double = 5.0 // 수성 속도 8초
//        let speedAdjustmentFactor = mercurySpeed / planetSpeeds[0]
//        
//        for i in 0..<planetNames.count {
//            let planetImageView = UIImageView(image: UIImage(named: planetNames[i]))
//            planetImageView.frame = CGRect(x: view.center.x + planetRadius[i], y: view.center.y, width: 24, height: 24)
//            planetImageView.clipsToBounds = true
//            planets.append(planetImageView)
//            view.addSubview(planetImageView)
//            
//            // 궤도 그리기
//            drawOrbit(radius: planetRadius[i])
//            
//            // 원형 경로 애니메이션 추가
//            let adjustedSpeed = planetSpeeds[i] * speedAdjustmentFactor  // 속도 비율에 맞춰 속도 조정
//            rotatePlanet(planetImageView: planetImageView, radius: planetRadius[i], speed: adjustedSpeed, randomizePosition: true)
//        }
//    }
//    
//    // 궤도를 그리는 함수 (원형 경로)
//    func drawOrbit(radius: CGFloat) {
//        let orbitLayer = CAShapeLayer()
//        let path = UIBezierPath(arcCenter: view.center, radius: radius, startAngle: 0, endAngle: 6.2832, clockwise: true) // 2π 대신 6.2832 사용
//        
//        orbitLayer.path = path.cgPath
//        orbitLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor  // 궤도의 색상
//        orbitLayer.fillColor = UIColor.clear.cgColor  // 궤도의 채우기 색상
//        orbitLayer.lineWidth = 1
//        view.layer.addSublayer(orbitLayer)
//    }
//    
//    // 행성 회전 애니메이션
//    func rotatePlanet(planetImageView: UIImageView, radius: CGFloat, speed: Double, randomizePosition: Bool = false) {
//        let orbitAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
//        orbitAnimation.values = [0, 6.2832]  // 2π 대신 6.2832 사용
//        orbitAnimation.keyTimes = [0, 1]
//        orbitAnimation.duration = speed
//        orbitAnimation.repeatCount = .infinity
//        orbitAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
//        
//        // 행성의 회전 애니메이션을 반복하도록 추가
//        planetImageView.layer.add(orbitAnimation, forKey: "orbit")
//        
//        // 행성 위치를 원형 궤도에 맞게 애니메이션
//        let moveAnimation = CAKeyframeAnimation(keyPath: "position")
//        var positions: [CGPoint] = []
//        
//        // 랜덤 초기 위치 설정
//        var initialAngle: CGFloat = 0
//        if randomizePosition {
//            initialAngle = CGFloat.random(in: 0...6.2832)  // 0부터 2π 사이의 랜덤 각도
//        }
//        
//        // 궤도 위의 초기 위치 계산
//        for i in 0..<360 {
//            let angle = initialAngle + CGFloat(i) * (6.2832 / 360)  // 2π 대신 6.2832 사용
//            let x = view.center.x + radius * cos(angle)
//            let y = view.center.y + radius * sin(angle)
//            positions.append(CGPoint(x: x, y: y))
//        }
//        
//        moveAnimation.values = positions
//        moveAnimation.duration = speed
//        moveAnimation.repeatCount = .infinity
//        moveAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
//        
//        planetImageView.layer.add(moveAnimation, forKey: "positionOrbit")
//    }
//}





import UIKit

class SolarSystemViewController: UIViewController {

    // 태양과 행성 이미지 뷰를 위한 변수
    var sunImageView: UIImageView!
    var planets: [UIImageView] = []
    var planetCardView: UIView!
    var planetLabel: UILabel!
    var currentPlanetIndex = 0
    
    let planetNames = ["수성", "금성", "지구", "화성", "목성", "토성", "천왕성", "해왕성"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경 색상 설정 (검은색으로 설정하여 우주 느낌을 낼 수 있음)
        view.backgroundColor = .black
        
        // 행성 카드 설정
        setupPlanetCard()
        
        // 카드 표시 버튼 추가
        addShowPlanetCardButton()
        
        // 태양 이미지 설정
        sunImageView = UIImageView(image: UIImage(named: "태양"))
        sunImageView.frame = CGRect(x: view.center.x - 15, y: view.center.y - 15, width: 30, height: 30)
        sunImageView.clipsToBounds = true
        view.addSubview(sunImageView)
        
        // 행성들 설정 (행성 개수만큼 추가)
        let planetRadius: [CGFloat] = [36, 55, 75, 95, 120, 140, 160, 190]  // 실제 거리 비율로 조정
        let planetSpeeds: [Double] = [2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]  // 속도 비율 설정
        
        // 수성을 느리게 하고 나머지 행성들도 비례하여 속도 조정
        let mercurySpeed: Double = 5.0 // 수성 속도 8초
        let speedAdjustmentFactor = mercurySpeed / planetSpeeds[0]
        
        for i in 0..<planetNames.count {
            let planetImageView = UIImageView(image: UIImage(named: planetNames[i]))
            planetImageView.frame = CGRect(x: view.center.x + planetRadius[i], y: view.center.y, width: 28, height: 28)
            planetImageView.clipsToBounds = true
            planets.append(planetImageView)
            view.addSubview(planetImageView)
            
            // 궤도 그리기
            drawOrbit(radius: planetRadius[i])
            
            // 원형 경로 애니메이션 추가
            let adjustedSpeed = planetSpeeds[i] * speedAdjustmentFactor  // 속도 비율에 맞춰 속도 조정
            rotatePlanet(planetImageView: planetImageView, radius: planetRadius[i], speed: adjustedSpeed, randomizePosition: true)
        }
        
        // 카드 외부 클릭 시 카드 숨기기 위한 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPlanetCard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // 궤도를 그리는 함수 (원형 경로)
    func drawOrbit(radius: CGFloat) {
        let orbitLayer = CAShapeLayer()
        let path = UIBezierPath(arcCenter: view.center, radius: radius, startAngle: 0, endAngle: 6.2832, clockwise: true)
        
        orbitLayer.path = path.cgPath
        orbitLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor  // 궤도의 색상
        orbitLayer.fillColor = UIColor.clear.cgColor  // 궤도의 채우기 색상
        orbitLayer.lineWidth = 1
        view.layer.addSublayer(orbitLayer)
    }
    
    // 행성 회전 애니메이션
    func rotatePlanet(planetImageView: UIImageView, radius: CGFloat, speed: Double, randomizePosition: Bool = false) {
        let orbitAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        orbitAnimation.values = [0, 6.2832]  // 2π 대신 6.2832 사용
        orbitAnimation.keyTimes = [0, 1]
        orbitAnimation.duration = speed
        orbitAnimation.repeatCount = .infinity
        orbitAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        // 행성의 회전 애니메이션을 반복하도록 추가
        planetImageView.layer.add(orbitAnimation, forKey: "orbit")
        
        // 행성 위치를 원형 궤도에 맞게 애니메이션
        let moveAnimation = CAKeyframeAnimation(keyPath: "position")
        var positions: [CGPoint] = []
        
        // 랜덤 초기 위치 설정
        var initialAngle: CGFloat = 0
        if randomizePosition {
            initialAngle = CGFloat.random(in: 0...6.2832)  // 0부터 2π 사이의 랜덤 각도
        }
        
        // 궤도 위의 초기 위치 계산
        for i in 0..<360 {
            let angle = initialAngle + CGFloat(i) * (6.2832 / 360)  // 2π 대신 6.2832 사용
            let x = view.center.x + radius * cos(angle)
            let y = view.center.y + radius * sin(angle)
            positions.append(CGPoint(x: x, y: y))
        }
        
        moveAnimation.values = positions
        moveAnimation.duration = speed
        moveAnimation.repeatCount = .infinity
        moveAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        planetImageView.layer.add(moveAnimation, forKey: "positionOrbit")
    }
    
    // 행성 카드 설정
    func setupPlanetCard() {
        planetCardView = UIView(frame: CGRect(x: 30, y: view.frame.height / 2 - 60, width: view.frame.width - 60, height: 120))
        planetCardView.backgroundColor = UIColor.white
        planetCardView.layer.cornerRadius = 10
        planetCardView.layer.zPosition = 1  // 카드가 행성보다 위에 위치하도록
        
        planetLabel = UILabel(frame: CGRect(x: 20, y: 20, width: planetCardView.frame.width - 40, height: 80))
        planetLabel.textAlignment = .center
        planetCardView.addSubview(planetLabel)
        
        // 화살표 버튼 추가
        let leftArrowButton = UIButton(frame: CGRect(x: 10, y: 40, width: 30, height: 30))
        leftArrowButton.setTitle("◀︎", for: .normal)
        leftArrowButton.setTitleColor(.blue, for: .normal)
        leftArrowButton.addTarget(self, action: #selector(previousPlanet), for: .touchUpInside)
        planetCardView.addSubview(leftArrowButton)
        
        let rightArrowButton = UIButton(frame: CGRect(x: planetCardView.frame.width - 40, y: 40, width: 30, height: 30))
        rightArrowButton.setTitle("▶︎", for: .normal)
        rightArrowButton.setTitleColor(.blue, for: .normal)
        rightArrowButton.addTarget(self, action: #selector(nextPlanet), for: .touchUpInside)
        planetCardView.addSubview(rightArrowButton)
        
        planetCardView.isHidden = true
        view.addSubview(planetCardView)
    }

    // 행성 카드 표시
    @objc func showPlanetCard() {
        planetLabel.text = planetNames[currentPlanetIndex]
        
        // 카드가 화면 아래에서 위로 슬라이드 되도록 애니메이션 추가
        planetCardView.isHidden = false
    }

    // 이전 행성 카드로 이동
    @objc func previousPlanet() {
        currentPlanetIndex = (currentPlanetIndex - 1 + planetNames.count) % planetNames.count
        planetLabel.text = planetNames[currentPlanetIndex]
    }

    // 다음 행성 카드로 이동
    @objc func nextPlanet() {
        currentPlanetIndex = (currentPlanetIndex + 1) % planetNames.count
        planetLabel.text = planetNames[currentPlanetIndex]
    }
    
    // 카드 외부를 클릭하면 카드 숨기기
    @objc func dismissPlanetCard(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        
        // 카드 외부를 클릭한 경우
        if !planetCardView.frame.contains(location) {
            planetCardView.isHidden = true
        }
    }
    
    // 카드 표시 버튼을 화면 아래에 추가하는 함수
    func addShowPlanetCardButton() {
         let showButton = UIButton(frame: CGRect(x: 30, y: view.frame.height - 100, width: view.frame.width - 60, height: 50))
         showButton.backgroundColor = UIColor.systemBlue
         showButton.setTitle("행성 카드 보기", for: .normal)
         showButton.layer.cornerRadius = 10
         showButton.addTarget(self, action: #selector(showPlanetCard), for: .touchUpInside)
         view.addSubview(showButton)
     }
}
