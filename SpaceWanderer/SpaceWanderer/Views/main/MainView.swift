//
//  MainView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit
import SnapKit

class MainView: UIView {
    let isSmallDevice = UIScreen.main.bounds.height <= 667 // iPhone SE (1세대) 기준

    // MARK: step label
    var stepLabel = UIFactory.makeLabel(text: "step", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .regular, size: 10, isScaled: true), textAlignment: .center)
    
    // MARK: success label & button
    var goalButton = UIFactory.makeView(backgroundColor: SpecialColors.MainViewBackGroundColor.withAlphaComponent(0.9))
    lazy var goalLabelStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [goalTitleLabel, goalLabel],
        axis: .vertical,
        spacing: 4,
        alignment: .center,
        distribution: .fill
    )
    lazy var goalTitleLabel = UIFactory.makeLabel(text: "축하합니다! 오늘 목표를 달성하셨습니다!", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .semiBold, size: isSmallDevice ? 16 : 18, isScaled: true), textAlignment: .center)
    lazy var goalLabel = UIFactory.makeLabel(text: "클릭 시 상세페이지로 이동", textColor: SpecialColors.WhiteColor.withAlphaComponent(0.6), font: UIFont.pretendard(style: .regular, size: self.isSmallDevice ? 14 : 16, isScaled: true), textAlignment: .center)
    var goalIconImage = UIFactory.makeImageView(imageName: "LargeRightIcon", color: SpecialColors.WhiteColor)

    // MARK: destination label & button
    var selectDestinationButton = UIFactory.makeView(backgroundColor: SpecialColors.MainViewBackGroundColor.withAlphaComponent(0.3))
    lazy var destinationStackView: UIStackView = UIFactory.makeStackView(
        arrangedSubviews: [selectDestinationLabel, destinationLabel, destinationIconImage],
        axis: .horizontal,
        spacing: 4,
        alignment: .center,
        distribution: .fill
    )
    var selectDestinationLabel = UIFactory.makeLabel(text: "목적지: ", textColor: SpecialColors.WhiteColor.withAlphaComponent(0.7), font: UIFont.pretendard(style: .bold, size: 24, isScaled: true), textAlignment: .center)
    var destinationLabel = UIFactory.makeLabel(text: "명왕성", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .bold, size: 24, isScaled: true), textAlignment: .center)
    var destinationIconImage = UIFactory.makeImageView(imageName: "LargeRightIcon", color: SpecialColors.WhiteColor)
    
    // MARK: Button Tapped
    var destinationButtonTapped: (() -> Void)?
    var goalButtonTapped: (() -> Void)?
    
    // MARK: loadingIndicator
    var loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.color = SpecialColors.WhiteColor
        $0.hidesWhenStopped = true
    }

    // MARK: ProgressBar
    private var progressLayer: CAShapeLayer!
    private var trackLayer: CAShapeLayer!
    private var progressImageView: UIImageView!
    private var progressMarkBackgroundView: UIView!
    private let radius: CGFloat = 150
    private let lineWidth: CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircularProgressBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateStepLabel(with steps: Int) {
        stepLabel.text = String(steps)
    }
    
    func showGoalMessage() {
        // goalButton 클릭 이벤트 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goalButtonTappedAction))
        goalButton.isUserInteractionEnabled = true // 터치 이벤트를 활성화
        goalButton.addGestureRecognizer(tapGesture)
        
        addSubview(goalButton)
        goalButton.addSubviews(goalLabelStackView)
                
        goalButton.snp.makeConstraints {
            $0.centerX.equalToSuperview() // 가로 중앙 정렬
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom).offset(isSmallDevice ? -90 : -150) // 조건에 따른 간격 설정
            $0.height.equalTo(40) // 버튼 높이
        }
        
        goalLabelStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(0) // 내부 여백 설정
            $0.center.equalToSuperview() // StackView가 버튼 안에서 중앙 정렬되도록
        }
        
        goalIconImage.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
    }
    
    func setDestinationUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(destinationButtonTappedAction))
        selectDestinationButton.isUserInteractionEnabled = true // 터치 이벤트를 활성화
        selectDestinationButton.addGestureRecognizer(tapGesture)
        
        addSubview(selectDestinationButton)
        selectDestinationButton.addSubviews(destinationStackView)
        
        selectDestinationButton.snp.makeConstraints {
            $0.centerX.equalToSuperview() // 가로 중앙 정렬
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(isSmallDevice ? 60 : 120) // 조건에 따른 간격 설정
            $0.height.equalTo(40) // 버튼 높이
        }
        
        destinationStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(0) // 내부 여백 설정
            $0.center.equalToSuperview() // StackView가 버튼 안에서 중앙 정렬되도록
        }
        
        destinationIconImage.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
    }
    
    @objc private func destinationButtonTappedAction() {
        destinationButtonTapped?() // 클로저 호출
    }
    
    @objc private func goalButtonTappedAction() {
        goalButtonTapped?()
    }
 
    // 로딩 인디케이터 시작
    func startLoading() {
        loadingIndicator.startAnimating()
        isUserInteractionEnabled = false // 사용자 인터랙션 비활성화
    }

    // 로딩 인디케이터 중지
    func stopLoading() {
        loadingIndicator.stopAnimating()
        isUserInteractionEnabled = true // 사용자 인터랙션 활성화
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // 트랙 레이어 및 프로그레스 레이어 다시 설정
        let radius: CGFloat = 150
        let lineWidth: CGFloat = 18
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        
        if trackLayer == nil {
            trackLayer = CAShapeLayer()
            let trackPath = UIBezierPath(
                arcCenter: centerPoint,
                radius: radius,
                startAngle: -CGFloat.pi / 2,
                endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
                clockwise: true
            )
            trackLayer.path = trackPath.cgPath
            trackLayer.strokeColor = SpecialColors.GearGray.cgColor.copy(alpha: 0.6)
            trackLayer.lineWidth = lineWidth
            trackLayer.fillColor = UIColor.clear.cgColor
            trackLayer.lineCap = .round
            layer.addSublayer(trackLayer)
            trackLayer.zPosition = -1 // 뒤로 보냄
        }

        if progressLayer == nil {
            progressLayer = CAShapeLayer()
            let progressPath = UIBezierPath(
                arcCenter: centerPoint,
                radius: radius,
                startAngle: -CGFloat.pi / 2,
                endAngle: -CGFloat.pi / 2,
                clockwise: true
            )
            progressLayer.path = progressPath.cgPath
            progressLayer.strokeColor = SpecialColors.GreenStarColor.cgColor
            progressLayer.lineWidth = lineWidth
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.lineCap = .round
            layer.addSublayer(progressLayer)
            progressLayer.zPosition = -1 // 뒤로 보냄
        }
    }

    func setupCircularProgressBar() {
        let backgroundDiameter: CGFloat = 40
        if progressMarkBackgroundView == nil {
            progressMarkBackgroundView = UIView()
            progressMarkBackgroundView.backgroundColor = SpecialColors.WhiteColor
            progressMarkBackgroundView.layer.cornerRadius = backgroundDiameter / 2
            addSubview(progressMarkBackgroundView)
            
            // SnapKit으로 progressBackgroundView의 제약 설정
            progressMarkBackgroundView.snp.makeConstraints {
                $0.width.height.equalTo(backgroundDiameter)
                $0.center.equalToSuperview()  // 부모 뷰의 중앙에 배치
            }
            
            // 내부 원
            let innerCircleView = UIView()
            let innerDiameter = backgroundDiameter - 4
            innerCircleView.backgroundColor = SpecialColors.GreenStarColor
            innerCircleView.layer.cornerRadius = innerDiameter / 2
            progressMarkBackgroundView.addSubview(innerCircleView)
            
            innerCircleView.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(2)
            }
        }
    }

    func updateCircularProgressBar(totalStepsToday: Double, realTimeSteps: Double) {
        let totalSteps = totalStepsToday + realTimeSteps
        let maxStepCount = 300.0
        let progress = totalSteps / maxStepCount
        
        let labelRadius: CGFloat = 150
        let endAngle = 2 * CGFloat.pi * CGFloat(progress) - CGFloat.pi / 2
        let xOffset = labelRadius * cos(endAngle)
        let yOffset = labelRadius * sin(endAngle)
        
        // progressBackgroundView의 위치를 변경하는 제약
        progressMarkBackgroundView.snp.updateConstraints {
            $0.centerX.equalToSuperview().offset(xOffset)
            $0.centerY.equalToSuperview().offset(yOffset)
        }
        
        // 프로그레스 레이어 업데이트
        let progressPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: labelRadius,
            startAngle: -CGFloat.pi / 2,
            endAngle: endAngle,
            clockwise: true
        )
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = progressPath.cgPath
        animation.duration = 0.5
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        progressLayer.add(animation, forKey: "path")
        progressLayer.path = progressPath.cgPath
    }
}
