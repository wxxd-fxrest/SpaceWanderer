//
//  UIViewController+StarView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/24/24.
//

import UIKit

extension UIViewController {
    func addStars(starCount: Int = 100) {
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
}
