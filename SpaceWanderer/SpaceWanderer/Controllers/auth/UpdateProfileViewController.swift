//
//  UpdateProfileViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/1/24.
//

import UIKit

class UpdateProfileViewController: CustomNavigationController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var userUniqueId: String?
    var userIdentifier: String?
    
    private let updateProfileView = UpdateProfileView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.PupleColor
        
        // userUniqueId와 userIdentifier를 사용하여 필요한 작업 수행
        if let uniqueId = userUniqueId {
            print("받은 userUniqueId: \(uniqueId)")
        }
        if let userIdentifier = userIdentifier {
            print("받은 userIdentifier: \(userIdentifier)")
        }

        setupUI()
        
        // 버튼 액션 설정
        updateProfileView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar(withTitle: "프로필 생성", backButtonImage: "")
        self.navigationItem.leftBarButtonItem = nil // 뒤로가기 버튼 제거
    }

    private func setupUI() {
        view.addSubview(updateProfileView)
        updateProfileView.frame = view.bounds // Fill the view
    }

    @objc func nextButtonTapped() {
        let nickname = updateProfileView.nicknameTextField.text ?? ""
        let birthDay = formatDateToString(updateProfileView.birthDayDatePicker.date)

        // nickname 유효성 검사
        let nicknamePattern = "^[a-zA-Z가-힣0-9]{2,12}$" // 영어, 한글, 숫자만 허용
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
        
        guard nicknamePredicate.evaluate(with: nickname) else {
            showAlert(title: "유효하지 않은 닉네임", message: "닉네임은 3자 이상, 12자 이하이며 특수문자를 포함할 수 없습니다.")
            return
        }
        
        // birthDay 유효성 검사 (YYYY-MM-DD 형식)
        let birthDayPattern = "^\\d{4}-\\d{2}-\\d{2}$" // YYYY-MM-DD 형식
        let birthDayPredicate = NSPredicate(format: "SELF MATCHES %@", birthDayPattern)
        
        guard birthDayPredicate.evaluate(with: birthDay) else {
            showAlert(title: "유효하지 않은 생일", message: "생일은 YYYY-MM-DD 형식으로 입력해주세요. 예: 1999-09-03")
            return
        }
        
        // APIManager를 사용하여 닉네임 중복 확인
        UserAPIManager.shared.checkNicknameUniqueness(nickname) { [weak self] isUnique in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if isUnique {
                    // SelectProfileImageViewController 인스턴스 생성 및 데이터 전달
                    let selectProfileVC = SelectProfileImageViewController()
                    selectProfileVC.userIdentifier = self.userIdentifier
                    selectProfileVC.nickname = nickname
                    selectProfileVC.birthDay = birthDay
                    
                    self.navigationController?.pushViewController(selectProfileVC, animated: true)
                } else {
                    self.showAlert(title: "중복된 닉네임", message: "이미 존재하는 닉네임입니다. 다른 닉네임을 입력해주세요.") {
                        self.updateProfileView.nicknameTextField.text = ""
                    }
                }
            }
        }
    }

    // Date를 "YYYY-MM-DD" 형식으로 변환하는 메서드
    private func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // 경고창 표시 메서드
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true, completion: nil)
    }
}
