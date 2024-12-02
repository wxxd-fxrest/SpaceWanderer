//
//  DestinationSelectionViewModel.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 12/2/24.
//

import Foundation

protocol DestinationSelectionViewModelDelegate: AnyObject {
    func didUpdatePlanets()
    func didFailFetchingPlanets(error: Error)
}

class DestinationSelectionViewModel {
    var userIdentifier: String?
    var totalGoals: String?
    
    var planets: [Planet] = []
    weak var delegate: DestinationSelectionViewModelDelegate?
    
    init(userIdentifier: String?, totalGoals: String?) {
        self.userIdentifier = userIdentifier
        self.totalGoals = totalGoals
    }
    
    func fetchPlanets() {
        PlanetAPIManager.shared.fetchPlanets { result in
            switch result {
            case .success(let planets):
                self.planets = planets
                self.delegate?.didUpdatePlanets()
                print("planet.requiredSteps: \(planets)")
            case .failure(let error):
                self.delegate?.didFailFetchingPlanets(error: error)
            }
        }
    }
    
    func updateUserPlanet(with planetName: String) {
        guard let userIdentifier = userIdentifier else { return }
        
        UserAPIManager.shared.updateUserPlanet(userIdentifier: userIdentifier, planetName: planetName) { result in
            switch result {
            case .success:
                print("User's planet updated successfully.")
                
                // NotificationCenter를 통해 알림 게시
                NotificationCenter.default.post(name: .planetUpdatedMain, object: nil)
                NotificationCenter.default.post(name: .planetUpdatedCalendar, object: nil)
                NotificationCenter.default.post(name: .planetUpdatedTabBar, object: nil)
                
            case .failure(let error):
                print("Error updating user's planet: \(error)")
            }
        }
    }
}
