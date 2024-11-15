//
//  BottomSheetPresentationController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/15/24.
//

import UIKit

class BottomSheetPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0, y: containerView.bounds.height * 0.5, width: containerView.bounds.width, height: containerView.bounds.height * 0.5) // 하단 절반 높이
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        // 어두운 배경 뷰 설정
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 원하는 투명도 설정
        dimmingView.alpha = 0
        containerView.insertSubview(dimmingView, at: 0)
        
        // 애니메이션 추가
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 1
        }, completion: nil)
        
        presentedView?.layer.cornerRadius = 15
        presentedView?.layer.masksToBounds = true
    }
}
