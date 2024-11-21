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
    
    var goGuestBookButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        setupDetailView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // 인스턴스 메서드로 호출
        setupNavigationBar(withTitle: "프로필 수정", backButtonImage: "LargeLeftIcon")
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
        
        dateLabel.text = "Date: \(formattedDate)" // 형식화된 날짜를 사용
        dateLabel.textColor = SpecialColors.WhiteColor
        
        stepsLabel.text = "Steps: \(steps)"
        stepsLabel.textColor = SpecialColors.WhiteColor
        
        destinationLabel.text = "행성: \(destination)"
        destinationLabel.textColor = SpecialColors.WhiteColor
        
        // selectDestinationButton 초기화 및 설정
        goGuestBookButton = UIButton()
        goGuestBookButton.setTitle("방명록", for: .normal)
        goGuestBookButton.tintColor = .gray // 텍스트 색상 설정
        goGuestBookButton.addTarget(self, action: #selector(navigateToGuestBook), for: .touchUpInside)
        
        // UI 설정
        view.addSubview(dateLabel)
        view.addSubview(stepsLabel)
        view.addSubview(destinationLabel)
        view.addSubview(goGuestBookButton)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        goGuestBookButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            stepsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            
            destinationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            destinationLabel.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 20),
            
            goGuestBookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goGuestBookButton.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 20),
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
