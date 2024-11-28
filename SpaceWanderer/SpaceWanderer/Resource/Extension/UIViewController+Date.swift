//
//  UIViewController+Date.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/28/24.
//

import UIKit

extension Date {
    // 오늘 날짜를 "yyyy-MM-dd" 형식으로 반환하는 메서드
    func getTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
