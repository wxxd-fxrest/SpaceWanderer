//
//  MainViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//

import UIKit

class MainViewController: UIViewController {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MainViewController Props: ", userUniqueId, accessToken, userIdentifier)
        
        // 배경 색상 설정
        view.backgroundColor = UIColor.black
        
        // 별과 행성 추가
        addStars()
        addPlanets()
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
}
