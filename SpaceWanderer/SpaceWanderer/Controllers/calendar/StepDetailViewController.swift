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
    
    private let blurBackgroundView = UIVisualEffectView(effect: nil) // 블러 효과 뷰

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.WhiteColor
        setupBlurBackground()
        setupDetailView()
        
        // 내부 요소 크기에 맞게 preferredContentSize 설정
        updatePreferredContentSize()
        
        // 날짜, 걸음 수, 목적지 출력
        print("StepDetailViewController 날짜: ", viewModel.date ?? "날짜 없음")
        print("StepDetailViewController 걸음 수: ", viewModel.steps ?? "걸음 수 없음")
        print("StepDetailViewController 목적지: ", viewModel.dayDestination ?? "목적지 없음")
    }
    
    private func setupBlurBackground() {
        // 블러 배경 추가
        blurBackgroundView.frame = view.bounds
        blurBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurBackgroundView, at: 0) // 바텀 시트 뒤로 배치
    }
    
    func showWithBlurEffect() {
        // 애니메이션으로 블러 효과 추가
        UIView.animate(withDuration: 0.3) {
            self.blurBackgroundView.effect = UIBlurEffect(style: .dark)
        }
    }
    
    func hideWithBlurEffect() {
        // 애니메이션으로 블러 효과 제거
        UIView.animate(withDuration: 0.3) {
            self.blurBackgroundView.effect = nil
        }
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
    
    private func updatePreferredContentSize() {
        // 내부 요소 크기에 맞게 preferredContentSize 업데이트
        let contentHeight = calculateContentHeight()
        preferredContentSize = CGSize(width: view.bounds.width, height: contentHeight)
    }
    
    private func calculateContentHeight() -> CGFloat {
        // 내부 요소의 총 높이를 계산
        // 여기서는 stepDetailView의 높이를 기준으로 설정
        return stepDetailView.frame.height
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
