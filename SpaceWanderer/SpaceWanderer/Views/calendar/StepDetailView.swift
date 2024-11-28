//
//  StepDetailView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class StepDetailView: UIView {
    
    // MARK: - UI Elements
    let dateLabel = UILabel()
    let stepsLabel = UILabel()
    let destinationLabel = UILabel()
    let imageView = UIImageView() // 이미지 뷰 추가
    let resultLabel = UILabel() // 성공/실패 메시지 라벨 추가
    var goGuestBookButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // UI 설정
        dateLabel.textColor = SpecialColors.WhiteColor
        stepsLabel.textColor = SpecialColors.WhiteColor
        destinationLabel.textColor = SpecialColors.WhiteColor
        resultLabel.textColor = SpecialColors.WhiteColor
        
        // 방명록 버튼 초기화 및 설정
        goGuestBookButton = UIButton()
        goGuestBookButton.setTitle("방명록", for: .normal)
        goGuestBookButton.tintColor = .gray
        
        // UI 요소 추가
        addSubview(dateLabel)
        addSubview(stepsLabel)
        addSubview(destinationLabel)
        addSubview(imageView)
        addSubview(goGuestBookButton)
        addSubview(resultLabel) // 성공/실패 메시지 라벨 추가
        
        // Auto Layout 설정
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        goGuestBookButton.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false // 성공/실패 라벨 제약 설정
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            
            stepsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            stepsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            
            destinationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            destinationLabel.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 20),
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            resultLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20), // 이미지 아래에 배치
            
            goGuestBookButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            goGuestBookButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
        ])
    }
    
    func configureView(date: Date, steps: Int, destination: String) {
        let formattedDate = formatDate(date)
        
        dateLabel.text = "Date: \(formattedDate)"
        stepsLabel.text = "Steps: \(steps)"
        destinationLabel.text = "행성: \(destination)"
        
        // 이미지 설정
        if let image = UIImage(named: destination) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "태양") // 기본 이미지 설정
        }
        
        // 성공/실패 메시지 라벨 설정
        if steps >= 10000 {
            resultLabel.text = "성공했습니다!"
        } else {
            resultLabel.text = "실패했습니다."
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // 출력 형식
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}
