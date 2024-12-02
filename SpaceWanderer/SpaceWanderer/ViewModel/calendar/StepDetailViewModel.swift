//
//  StepDetailViewModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 12/2/24.
//

import Foundation

class StepDetailViewModel {
    var date: Date?
    var steps: Int?
    var dayDestination: String?
    
    init(date: Date?, steps: Int?, dayDestination: String?) {
        self.date = date
        self.steps = steps
        self.dayDestination = dayDestination
    }
    
    func formattedDate() -> String {
        guard let date = date else { return "날짜 없음" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func configureDetailView() -> (date: Date, steps: Int, destination: String)? {
        guard let date = date, let steps = steps, let destination = dayDestination else {
            return nil
        }
        return (date, steps, destination)
    }
}
