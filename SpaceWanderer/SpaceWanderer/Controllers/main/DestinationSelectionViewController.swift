//
//  DestinationSelectionViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/12/24.
//

import UIKit

class DestinationSelectionViewController: CustomNavigationController {
    var userIdentifier: String?
    var totalGoals: String?
    
    var viewModel: DestinationSelectionViewModel!
    
    private var destinationSelectionView: DestinationSelectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DestinationSelectionViewController userIdentifier: ", userIdentifier ?? "")
        print("DestinationSelectionViewController totalGoals: ", totalGoals ?? "")
        
        setupUI()
        setupViewModel()
        viewModel.fetchPlanets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(withTitle: "목적지 선택", backButtonImage: "LargeLeftIcon")
    }
    
    private func setupUI() {
        // DestinationSelectionView 인스턴스화
        destinationSelectionView = DestinationSelectionView(frame: self.view.bounds)
        destinationSelectionView.tableView.delegate = self
        destinationSelectionView.tableView.dataSource = self
        destinationSelectionView.tableView.register(PlanetCell.self, forCellReuseIdentifier: "PlanetCell")
        view.addSubview(destinationSelectionView)
    }
    
    private func setupViewModel() {
        viewModel = DestinationSelectionViewModel(userIdentifier: userIdentifier, totalGoals: totalGoals)
        viewModel.delegate = self
    }
}

extension DestinationSelectionViewController: DestinationSelectionViewModelDelegate {
    func didUpdatePlanets() {
        DispatchQueue.main.async {
            // 테이블 뷰 갱신
            self.destinationSelectionView.tableView.reloadData()
        }
    }
    
    func didFailFetchingPlanets(error: Error) {
        print("Error fetching planets: \(error)")
    }
}
