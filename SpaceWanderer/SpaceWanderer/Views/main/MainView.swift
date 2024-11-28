//
//  MainView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class MainView: UIView {
    
    var stepLabel: UILabel!
    var goalLabel: UILabel!
    var selectDestinationButton: UIButton!
    var destinationLabel: UILabel!
    
    var destinationButtonTapped: (() -> Void)?
    
    var loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.color = SpecialColors.WhiteColor
        $0.hidesWhenStopped = true
    }

    private var progressLayer: CAShapeLayer!
    private var trackLayer: CAShapeLayer!
    private var progressImageView: UIImageView!
    private var progressBackgroundView: UIView!
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
        goalLabel = UILabel()
        goalLabel.text = "축하합니다! 오늘 10,000걸음 목표를 달성하셨습니다!"
        goalLabel.textAlignment = .center
        goalLabel.textColor = .red
        addSubview(goalLabel)
        
        selectDestinationButton = UIButton()
        selectDestinationButton.setTitle(">", for: .normal)
        selectDestinationButton.tintColor = .red
        addSubview(selectDestinationButton)
        
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        selectDestinationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            goalLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            goalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            selectDestinationButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            selectDestinationButton.leadingAnchor.constraint(equalTo: goalLabel.trailingAnchor, constant: 6),
            selectDestinationButton.heightAnchor.constraint(equalToConstant: 30),
            selectDestinationButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func setDestinationUI() {
        // 목적지 선택 버튼 및 행성 라벨
        stepLabel = UILabel()
        stepLabel.textAlignment = .center
        stepLabel.frame = CGRect(x: (frame.width - 200) / 2, y: (frame.height - 80) / 2, width: 200, height: 50)
        stepLabel.textColor = .blue
        
        selectDestinationButton = UIButton()
        selectDestinationButton.setTitle("목적지 선택", for: .normal)
        selectDestinationButton.frame = CGRect(x: (frame.width - 120) / 2, y: 40, width: 200, height: 50)
        selectDestinationButton.tintColor = .blue
        selectDestinationButton.addTarget(self, action: #selector(destinationButtonTappedAction), for: .touchUpInside)
        
        destinationLabel = UILabel()
        destinationLabel.textAlignment = .center
        destinationLabel.frame = CGRect(x: (frame.width - 300) / 2, y: 40, width: 200, height: 50)
        destinationLabel.textColor = .blue
        
        addSubviews(stepLabel, selectDestinationButton, destinationLabel)
    }
    
    @objc private func destinationButtonTappedAction() {
        destinationButtonTapped?() // 클로저 호출
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
        let lineWidth: CGFloat = 16
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
        let backgroundDiameter: CGFloat = 44
        if progressBackgroundView == nil {
            progressBackgroundView = UIView()
            progressBackgroundView.backgroundColor = SpecialColors.WhiteColor
            progressBackgroundView.layer.cornerRadius = backgroundDiameter / 2
            addSubview(progressBackgroundView)

            // progressBackgroundView를 최상단으로 가져옴
            bringSubviewToFront(progressBackgroundView)

            progressBackgroundView.snp.makeConstraints {
                $0.width.height.equalTo(backgroundDiameter)
                $0.center.equalToSuperview()
            }

            let innerCircleView = UIView()
            let innerDiameter = backgroundDiameter - 4
            innerCircleView.backgroundColor = SpecialColors.GreenStarColor
            innerCircleView.layer.cornerRadius = innerDiameter / 2
            progressBackgroundView.addSubview(innerCircleView)
            
            if progressImageView == nil {
                let progressImage = UIImage(named: "flyAlien")
                progressImageView = UIImageView(image: progressImage)
                progressImageView.contentMode = .scaleAspectFit
                let imageSize: CGFloat = 42
                progressImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
                progressBackgroundView.addSubview(progressImageView)
                progressImageView.center = CGPoint(x: backgroundDiameter / 2, y: backgroundDiameter / 2)
            }

            innerCircleView.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(2) // 바깥쪽 여백
            }
        }
    }

    func updateCircularProgressBar(totalStepsToday: Double, realTimeSteps: Double) {
        let totalSteps = totalStepsToday + realTimeSteps
        let maxStepCount = 20.0
        let progress = totalSteps / maxStepCount
        
        let labelRadius: CGFloat = 150
        let endAngle = 2 * CGFloat.pi * CGFloat(progress) - CGFloat.pi / 2
        let xOffset = labelRadius * cos(endAngle)
        let yOffset = labelRadius * sin(endAngle)
        
        progressBackgroundView.snp.updateConstraints {
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
