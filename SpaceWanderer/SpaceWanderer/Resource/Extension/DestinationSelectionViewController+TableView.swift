//
//  DestinationSelectionViewController+TableView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

// MARK: - UITableViewDelegate & UITableViewDataSource
extension DestinationSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.planets.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // 원하는 셀 높이
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let planet = viewModel.planets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanetCell", for: indexPath) as! PlanetCell
        
        // 셀 데이터 설정
        cell.planetNameLabel.text = planet.name
        cell.backgroundColor = SpecialColors.MainViewBackGroundColor
        cell.planetImageView.image = UIImage(named: planet.planetImage)
        cell.requiredStepsLabel.text = "필요 단계: \(planet.stepsRequired)"
        
        // totalGoals와 steps_required 비교
        if let totalGoalsInt = Int(totalGoals ?? "0"), totalGoalsInt >= planet.stepsRequired {
            cell.planetNameLabel.textColor = SpecialColors.WhiteColor
            cell.requiredStepsLabel.textColor = SpecialColors.WhiteColor
            cell.isUserInteractionEnabled = true
        } else {
            cell.planetNameLabel.textColor = .darkGray
            cell.requiredStepsLabel.textColor = .darkGray
            cell.isUserInteractionEnabled = false
        }

        // 셀 선택 시 배경색 설정
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = SpecialColors.MainColor.withAlphaComponent(0.3)
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlanet = viewModel.planets[indexPath.row]
        viewModel.updateUserPlanet(with: selectedPlanet.name)
        self.navigationController?.popViewController(animated: true)
    }
}
