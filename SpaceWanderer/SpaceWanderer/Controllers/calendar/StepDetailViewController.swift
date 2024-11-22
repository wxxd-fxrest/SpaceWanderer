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
    
    let dateLabel = UILabel()
    let stepsLabel = UILabel()
    let destinationLabel = UILabel()
    let imageView = UIImageView() // 이미지 뷰 추가
    let resultLabel = UILabel() // 성공/실패 메시지 라벨 추가
    
    var goGuestBookButton: UIButton!
    
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
            let formattedDate = formatDate(unwrappedDate)
            setupNavigationBar(withTitle: formattedDate, backButtonImage: "LargeLeftIcon")
        } else {
            setupNavigationBar(withTitle: "날짜 없음", backButtonImage: "LargeLeftIcon")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // 출력 형식
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    private func setupDetailView() {
        guard let date = date, let steps = steps, let destination = dayDestination else { return }
        
        // 날짜 및 걸음 수 출력
        let formattedDate = formatDate(date)
        print("날짜: \(formattedDate), 걸음 수: \(steps)")
        
        dateLabel.text = "Date: \(formattedDate)"
        dateLabel.textColor = SpecialColors.WhiteColor
        
        stepsLabel.text = "Steps: \(steps)"
        stepsLabel.textColor = SpecialColors.WhiteColor
        
        destinationLabel.text = "행성: \(destination)"
        destinationLabel.textColor = SpecialColors.WhiteColor
        
        // 이미지 설정
        if let image = UIImage(named: destination) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "태양") // 기본 이미지 설정
        }
        
        // 성공/실패 메시지 라벨 설정
        resultLabel.textColor = SpecialColors.WhiteColor
        if steps >= 10000 {
            resultLabel.text = "성공했습니다!"
        } else {
            resultLabel.text = "실패했습니다."
        }
        
        // selectDestinationButton 초기화 및 설정
        goGuestBookButton = UIButton()
        goGuestBookButton.setTitle("방명록", for: .normal)
        goGuestBookButton.tintColor = .gray
        goGuestBookButton.addTarget(self, action: #selector(navigateToGuestBook), for: .touchUpInside)
        
        // UI 설정
        view.addSubview(dateLabel)
        view.addSubview(stepsLabel)
        view.addSubview(destinationLabel)
        view.addSubview(imageView)
        view.addSubview(goGuestBookButton)
        view.addSubview(resultLabel) // 성공/실패 메시지 라벨 추가
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        goGuestBookButton.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false // 성공/실패 라벨 제약 설정
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            stepsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            
            destinationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            destinationLabel.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 20),
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20), // 이미지 아래에 배치
            
            goGuestBookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goGuestBookButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
        ])
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
