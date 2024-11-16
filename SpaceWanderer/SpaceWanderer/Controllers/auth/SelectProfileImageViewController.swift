//
//  SelectProfileImageViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/4/24.
//

import UIKit

class SelectProfileImageViewController: UIViewController {
    
    // MainViewController에서 전달받을 데이터
    var userIdentifier: String?
    var nickname: String?
    var birthDay: String?

    private let imageNames = ["spaceProfile1", "spaceProfile2"] // Assets에 있는 이미지 이름
    private var selectedImageName: String?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad : ", nickname, birthDay)
        print("viewDidLoad - userIdentifier: ", userIdentifier)

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        let imageButton1 = createImageButton(named: imageNames[0], tag: 0)
        imageButton1.frame = CGRect(x: 50, y: 100, width: 100, height: 100)
        view.addSubview(imageButton1)
        
        let imageButton2 = createImageButton(named: imageNames[1], tag: 1)
        imageButton2.frame = CGRect(x: 200, y: 100, width: 100, height: 100)
        view.addSubview(imageButton2)
        
        // 확인 버튼 추가
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.frame = CGRect(x: 125, y: 250, width: 100, height: 50)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        // 버튼이 항상 가장 위에 오도록 설정
        view.bringSubviewToFront(imageButton1)
        view.bringSubviewToFront(imageButton2)
        view.bringSubviewToFront(confirmButton)
    }

    private func createImageButton(named imageName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tag = tag
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
        
        // 버튼이 상호작용할 수 있도록 설정
        button.isUserInteractionEnabled = true
        return button
    }

    @objc private func imageButtonTapped(_ sender: UIButton) {
        print("Image button tapped with tag: \(sender.tag)")
        selectedImageName = imageNames[sender.tag]
        print("selectedImageName: ", selectedImageName)
    }
    
    // 확인 버튼을 눌렀을 때 호출되는 메서드
    @objc private func confirmButtonTapped() {
        guard let selectedImageName = selectedImageName else {
            showAlert(title: "이미지 선택", message: "프로필 이미지를 선택해주세요.")
            print("이미지를 선택해주세요.")
            return
        }
        updateProfile(imageName: selectedImageName)
    }
    
    // 서버로 데이터와 이미지 이름을 업로드하는 메서드
    private func updateProfile(imageName: String) {
        guard let nickname = nickname,
              let birthDay = birthDay else {
            print("Missing user data")
            return
        }
        print("updateProfile : ", nickname, birthDay)
        
        guard let userIdentifier = userIdentifier else { return }
        print("updateProfile : ", userIdentifier)
        
        // URL 요청 준비
        guard let url = URL(string: "\(backendURL)/profile-write/\(userIdentifier)") else { return }
        var request = URLRequest(url: url)
        print("updateProfile : ", url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData: [String: Any] = [
            "nickname": nickname,
            "birthDay": birthDay,
            "inhabitedPlanet": "화성",
            "profileImage": imageName
        ]
        print("updateProfile - requestData : ", requestData)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error updating profile: \(error)")
                    return
                }
                
                guard let data = data else { return }
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Profile updated: \(responseString)")
                    
                    // 프로필 업데이트 성공 후 ViewController로 이동
                   DispatchQueue.main.async {
                       self.navigateToViewController()
                   }
                }
            }
            task.resume()
            
        } catch {
            print("Error serializing profile data: \(error)")
        }
    }
    
    private func navigateToViewController() {
        let viewController = ViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Alert helper method
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
