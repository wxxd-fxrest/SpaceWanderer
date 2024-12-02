//
//  StepDetailViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/17/24.
//

import UIKit

class StepDetailViewController: CustomNavigationController {
    var viewModel: StepDetailViewModel! // StepDetailViewModel 인스턴스
    
    private let stepDetailView = StepDetailView() // StepDetailView 인스턴스

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        setupDetailView()
        
        // 날짜, 걸음 수, 목적지 출력
        print("StepDetailViewController 날짜: ", viewModel.date ?? "날짜 없음")
        print("StepDetailViewController 걸음 수: ", viewModel.steps ?? "걸음 수 없음")
        print("StepDetailViewController 목적지: ", viewModel.dayDestination ?? "목적지 없음")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        // 뷰 모델에서 날짜를 포맷해서 네비게이션 바 타이틀에 설정
        let formattedDate = viewModel.formattedDate()
        setupNavigationBar(withTitle: formattedDate, backButtonImage: "LargeLeftIcon")
    }
    
    private func setupDetailView() {
        // 뷰 모델에서 데이터를 가져와 뷰를 설정
        if let viewData = viewModel.configureDetailView() {
            stepDetailView.configureView(date: viewData.date, steps: viewData.steps, destination: viewData.destination)
            
            // UI 설정
            view.addSubview(stepDetailView)
            stepDetailView.frame = view.bounds // 전체 화면에 맞게 설정
        }
    }
    
    @objc private func navigateToGuestBook() {
        let alertController = UIAlertController(title: "알림", message: "아직 개발중인 기능입니다", preferredStyle: .alert)
        
        // OK 버튼 추가
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 알림 표시
        present(alertController, animated: true, completion: nil)
//        let guestBookVC = GuestBookViewController()
//        guestBookVC.hidesBottomBarWhenPushed = true // 탭 바 숨기기
//        navigationController?.pushViewController(guestBookVC, animated: true)
    }
}
