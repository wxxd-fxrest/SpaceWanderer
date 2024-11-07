//
//  UpdateProfileViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/1/24.
//

import UIKit

class UpdateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    lazy var backendURL: String = {
        // Space.plist에서 BackendURL 가져오기
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["PROFILE_BASE_URL"] as? String {
            print("PROFILE_BASE_URL", backendURL)
            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020" // 기본값 설정
        }
    }()
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Nickname"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let birthDayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        // 오늘 날짜로부터 10년 전 날짜 설정
        let calendar = Calendar.current
        let tenYearsAgo = calendar.date(byAdding: .year, value: -10, to: Date())!
        datePicker.maximumDate = tenYearsAgo // 10년 전 날짜 설정
        return datePicker
    }()

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // userUniqueId와 accessToken, userIdentifier를 사용하여 필요한 작업 수행
        if let uniqueId = userUniqueId {
            print("받은 userUniqueId: \(uniqueId)")
            // 추가 작업 수행
        }
        if let userIdentifier = userIdentifier {
            print("받은 userIdentifier: \(userIdentifier)")
            // 추가 작업 수행
        }
        if let accessToken = accessToken {
            print("받은 accessToken: \(accessToken)")
            // 추가 작업 수행
        }
        
        setupUI()
    }
    
    func setupUI() {
        [nicknameTextField, birthDayDatePicker, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Set up constraints
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            birthDayDatePicker.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
                   birthDayDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                   birthDayDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                   
            nextButton.topAnchor.constraint(equalTo: birthDayDatePicker.bottomAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func nextButtonTapped() {
        let nickname = nicknameTextField.text ?? ""
        let birthDay = formatDateToString(birthDayDatePicker.date)

        // nickname 유효성 검사
        let nicknamePattern = "^[a-zA-Z가-힣0-9]{3,12}$" // 영어, 한글, 숫자만 허용
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
        
        // 닉네임 중복 확인
        checkNicknameUniqueness(nickname) { [weak self] isUnique in
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
                        self.nicknameTextField.text = ""
                    }
                }
            }
        }
    }

    // 서버에서 닉네임 중복 확인
    private func checkNicknameUniqueness(_ nickname: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(backendURL)/check-nickname/\(nickname)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error checking nickname uniqueness: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                // Correctly decoding the response as a Bool
                let responseObject = try JSONDecoder().decode(Bool.self, from: data)
                completion(responseObject)
            } catch {
                print("Error decoding response: \(error)")
                completion(false)
            }
        }
        task.resume()
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

