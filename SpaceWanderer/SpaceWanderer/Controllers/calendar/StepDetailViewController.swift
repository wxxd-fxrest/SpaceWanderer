//
//  StepDetailViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/17/24.
//

import UIKit

class StepDetailViewController: CustomNavigationController {
    var date: Date?
    var steps: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        setupDetailView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // 인스턴스 메서드로 호출
        setupNavigationBar(withTitle: "프로필 수정", backButtonImage: "LargeLeftIcon")
    }

    private func setupDetailView() {
        guard let date = date, let steps = steps else { return }
        
        let dateLabel = UILabel()
        dateLabel.text = "Date: \(date)"
        dateLabel.textColor = SpecialColors.WhiteColor
        let stepsLabel = UILabel()
        stepsLabel.text = "Steps: \(steps)"
        stepsLabel.textColor = SpecialColors.WhiteColor
        
        view.addSubview(dateLabel)
        view.addSubview(stepsLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            stepsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20)
        ])
    }
}
