//
//  PlanetView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/28/24.
//

import UIKit

class AddPlanetView: UIView {
    
    func addPlanets(to view: UIView) {
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
    
    // 가운데 행성 이미지
    // 사용자가 선택한 행성 이름 받아서 변경하도록 해야 함 
    private var marsImageView: UIImageView!

    func addMarsImage(to view: UIView) {
        let marsImage = UIImage(named: "flyAlien") // "mars"는 화성 이미지 파일 이름
        marsImageView = UIImageView(image: marsImage)
        marsImageView.frame = CGRect(x: view.center.x - 90, y: view.center.y - 90, width: 180, height: 180)
        marsImageView.contentMode = .scaleAspectFit
        view.addSubview(marsImageView)
    }
}
