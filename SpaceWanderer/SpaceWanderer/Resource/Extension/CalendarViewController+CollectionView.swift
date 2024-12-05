//
//  CalendarViewController+CollectionView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.calendarView.planetCollectionView {
            return planets.count
        } else {
            return dates.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.calendarView.calendarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
            let date = dates[indexPath.item]
            let steps = stepData[date]?.0 ?? 0
            
            cell.configure(date: date, steps: steps)
            return cell
        } else if collectionView == self.calendarView.planetCollectionView {
            guard indexPath.item < planets.count else {
                fatalError("\(indexPath.item) 행성 배열의 경우 범위를 벗어난 인덱스입니다.")
            }
            
            let planet = planets[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarPlanetCell", for: indexPath) as! CalendarPlanetCell
            
            cell.configure(planet: planet.name)
            
            if let totalGoalsInt = Int(totalGoals ?? "0"), totalGoalsInt >= planet.stepsRequired {
                cell.planetLabel.textColor = .white
                cell.isUserInteractionEnabled = true
            } else {
                cell.planetLabel.textColor = .darkGray
                cell.isUserInteractionEnabled = false
            }
            
            return cell
        }
        fatalError("예상치 못한 컬렉션 보기")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 16) / 7 // 7일이 일주일
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.calendarView.calendarCollectionView {
            let selectedDate = dates[indexPath.item]
            navigateToDetailPage(for: selectedDate)
        } else if collectionView == self.calendarView.planetCollectionView {
            let selectedPlanet = planets[indexPath.item]
            navigateToPlanetDetailPage(for: selectedPlanet)
        }
    }
    
//    private func navigateToDetailPage(for date: Date) {
//        let detailVC = StepDetailViewController()
//
//        // 해당 날짜에 대한 걸음 수와 목적지 가져오기
//        let stepDataForSelectedDate = stepData[date] ?? (0, "")
//        
//        // StepDetailViewModel 생성
//        let viewModel = StepDetailViewModel(date: date, steps: stepDataForSelectedDate.0, dayDestination: stepDataForSelectedDate.1)
//        
//        // 뷰 모델 설정
//        detailVC.viewModel = viewModel
//        
//        detailVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
    private func navigateToDetailPage(for date: Date) {
        let detailVC = StepDetailViewController()

        // 해당 날짜에 대한 걸음 수와 목적지 가져오기
        let stepDataForSelectedDate = stepData[date] ?? (0, "")
        
        // StepDetailViewModel 생성
        let viewModel = StepDetailViewModel(date: date, steps: stepDataForSelectedDate.0, dayDestination: stepDataForSelectedDate.1)
        
        // 뷰 모델 설정
        detailVC.viewModel = viewModel
        
        // 바텀 시트 설정
        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [
                .custom { _ in 300 } // 기본 높이 설정 (필요 시 변경 가능)
            ]
            sheet.prefersGrabberVisible = true // 바텀 시트 위쪽에 핸들 표시
            sheet.prefersEdgeAttachedInCompactHeight = true // 컴팩트 모드에서 화면 가장자리 고정
        }
        
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
    
    private func filteredStepData(for planet: Planet) -> [Date: Int] {
        var filteredData: [Date: Int] = [:]
        
        print("Current stepData: ", stepData)
        print("Filtering for planet: ", planet.name)
        
        for (date, (steps, destination)) in stepData {
            if destination == planet.name {
                filteredData[date] = steps
            }
        }
        
        print("filteredData: ", filteredData)
        return filteredData
    }

    private func navigateToPlanetDetailPage(for planet: Planet) {
        let planetDetailVC = PlanetDetailViewController()
        
        let filteredData = filteredStepData(for: planet)
        planetDetailVC.filteredStepData = filteredData
        planetDetailVC.planet = planet

        planetDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(planetDetailVC, animated: true)
    }
}

extension CalendarViewController: UIViewControllerTransitioningDelegate, MonthSelectionViewControllerDelegate {
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    // MARK: - MonthSelectionViewControllerDelegate
    func didSelectDate(_ date: Date) {
        guard let userUniqueId = userUniqueId else {
            print("userUniqueId is nil")
            return // 조건이 충족되지 않으면 이 함수에서 빠져나갑니다.
        }
        
        selectedDate = date
        setupDates()
        
        let year = Calendar.current.component(.year, from: selectedDate)
        let month = Calendar.current.component(.month, from: selectedDate)
        // ViewModel을 사용하여 데이터 가져오기
        viewModel.fetchStepData(for: userUniqueId, year: year, month: month) { result in
            switch result {
            case .success(let stepData):
                DispatchQueue.main.async {
                    self.stepData = stepData
                    self.updateTotalStepsLabel()
                    self.calendarView.calendarCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching step data: \(error.localizedDescription)")
            }
        }
        
        updateMonthLabel()
        updateTotalStepsLabel()
    }
}
