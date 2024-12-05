//
//  UIColor.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/3/24.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(hex: String) {

        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }

        guard hex.count == 6 else {
            self.init(cgColor: UIColor.gray.cgColor)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        self.init(
            red:   CGFloat((rgbValue & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255,
            blue:  CGFloat(rgbValue & 0x0000FF) / 255,
            alpha: 1
        )
    }
}

enum SpecialColors {
    //hex code
    static let MainColor = UIColor(hex: "#12A76E")
    static let TabSelectColor = UIColor(hex: "#D8E5F3")
    static let TabUnSelectColor = UIColor(hex: "#C8D2DE")
    static let WhiteColor = UIColor(hex: "#F9F9F9")
    
    static let DarkGreenColor = UIColor(hex: "#071209")
    static let BlackColor = UIColor(hex: "#070707")
    static let GreenColor = UIColor(hex: "#6fea98")
    static let PupleColor = UIColor(hex: "#090909")
//    static let Gray3 = UIColor(hex: "#9E9E9E")
//    static let Gray4 = UIColor(hex: "#555555")
//    static let Black = UIColor(hex: "#2D2D2D")
//    static let Red = UIColor(hex: "#EE2000")
    // 추가
    static let Blue = UIColor(hex: "#77CFC8")
    static let DayBlue = UIColor(hex: "#C5F4E2")

    static let GearGray = UIColor(hex: "#646464")
    static let Mint = UIColor(hex: "#DFF4F1")
    
    // Launch, Main View Background Color
    static let MainViewBackGroundColor = UIColor(hex: "#090909")
    
    // 행성 색상
    static let PinkStarColor = UIColor(hex: "#e9bace")
    static let BlueStarColor = UIColor(hex: "#5f86c7")
    static let GreenStarColor = UIColor(hex: "#3fc0a1")
    static let WhiteStarColor = UIColor(hex: "##F9F9F9")
    
    // 프로그레스 바
    static let ProgressBarColor = UIColor(hex: "#F9F9F9")
    
    // kakao login button
    static let KakaoButtonBackgroundColor = UIColor(hex: "#FEE500")

    //color asset
    static let customColor  = UIColor(named: "")
}
