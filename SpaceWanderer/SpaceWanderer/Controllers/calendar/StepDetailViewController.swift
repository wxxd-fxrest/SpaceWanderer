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
    var dayDestination: String?
    
    private let stepDetailView = StepDetailView() // StepDetailView 인스턴스

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        setupDetailView()
        
        print("StepDetailViewController 날짜: ", date ?? "날짜 없음")
        print("StepDetailViewController 걸음 수: ", steps ?? "걸음 수 없음")
        print("StepDetailViewController 목적지: ", dayDestination ?? "목적지 없음")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        if let unwrappedDate = date {
            let formattedDate = stepDetailView.formatDate(unwrappedDate)
            setupNavigationBar(withTitle: formattedDate, backButtonImage: "LargeLeftIcon")
        } else {
            setupNavigationBar(withTitle: "날짜 없음", backButtonImage: "LargeLeftIcon")
        }
    }
    
    private func setupDetailView() {
        guard let date = date, let steps = steps, let destination = dayDestination else { return }
        
        stepDetailView.configureView(date: date, steps: steps, destination: destination)
        
        // UI 설정
        view.addSubview(stepDetailView)
        stepDetailView.frame = view.bounds // 전체 화면에 맞게 설정
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
