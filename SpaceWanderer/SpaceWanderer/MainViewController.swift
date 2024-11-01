//
//  MainViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/1/24.
//

import UIKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var userUniqueId: String?
    var accessToken: String?
    var userIdentifier: String?
    
    let kakaoLoginManager = KakaoLoginManager() // KakaoLoginManager 인스턴스 생성
    let appleLoginManager = AppleLoginManager() // AppleLoginManager 인스턴스 생성
    
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

    let birthDayTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Birth Day (YYYY-MM-DD)"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let inhabitedPlanetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Inhabited Planet"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Profile Image", for: .normal)
        button.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
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
        setupLogoutButton() // 로그아웃 버튼 설정
    }
    
    func setupUI() {
        // Add all UI elements to the main view
        [nicknameTextField, birthDayTextField, inhabitedPlanetTextField, profileImageView, selectImageButton, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Set up constraints
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            birthDayTextField.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            birthDayTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            birthDayTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            inhabitedPlanetTextField.topAnchor.constraint(equalTo: birthDayTextField.bottomAnchor, constant: 20),
            inhabitedPlanetTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inhabitedPlanetTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            profileImageView.topAnchor.constraint(equalTo: inhabitedPlanetTextField.bottomAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            selectImageButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: selectImageButton.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func selectImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped() {
        // Retrieve values entered by the user
        let nickname = nicknameTextField.text ?? ""
        let birthDay = birthDayTextField.text ?? ""
        let inhabitedPlanet = inhabitedPlanetTextField.text ?? ""
        let profileImage = profileImageView.image
        
        // Here, you can handle the save action, e.g., send data to the server or save locally.
        print("Nickname: \(nickname)")
        print("Birth Day: \(birthDay)")
        print("Inhabited Planet: \(inhabitedPlanet)")
        print("Profile Image: \(profileImage != nil ? "Image Selected" : "No Image")")
        
        // Call the API to update the profile
      updateProfile(nickname: nickname, birthDay: birthDay, inhabitedPlanet: inhabitedPlanet, profileImage: profileImage)
    }
    
    private func updateProfile(nickname: String?, birthDay: String?, inhabitedPlanet: String?, profileImage: UIImage?) {
        guard let userIdentifier = userIdentifier else { return }
        
        // Prepare the request URL
        guard let url = URL(string: "\(backendURL)/profile-update/\(userIdentifier)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the profile data
        var profileData: [String: Any] = [:]
        
        if let nickname = nickname {
            profileData["nickname"] = nickname
        }
        if let birthDay = birthDay {
            profileData["birthDay"] = birthDay
        }
        if let inhabitedPlanet = inhabitedPlanet {
            profileData["inhabitedPlanet"] = inhabitedPlanet
        }
        if let imageData = profileImage?.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            
            // Base64 문자열의 길이를 확인합니다.
            print("Base64 문자열의 길이: \(base64String.count)")

            profileData["profileImage"] = base64String
        }

        // Convert the profile data to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: profileData, options: [])
            request.httpBody = jsonData
            
            // Perform the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error updating profile: \(error)")
                    return
                }
                
                guard let data = data else { return }
                // Handle the response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Profile updated: \(responseString)")
                }
            }
            task.resume()
            
        } catch {
            print("Error serializing profile data: \(error)")
        }
    }

    // UIImagePickerControllerDelegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // 선택된 이미지를 원하는 크기로 조정합니다 (예: 300x300)
            let targetSize = CGSize(width: 120, height: 120)
            let resizedImage = selectedImage.resizeImage(targetSize: targetSize)
            
            // 크기 조정된 이미지를 프로필 이미지 뷰에 설정
            profileImageView.image = resizedImage
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupLogoutButton() {
        // 로그아웃 버튼 생성 및 속성 설정
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.layer.cornerRadius = 8
        logoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        // 버튼 레이아웃 설정
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        // 버튼 위치 제약 설정 (카카오 로그인 버튼 아래)
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func handleLogout() {
        // UserDefaults에서 로그인 타입 확인
        if let loginType = UserDefaults.standard.string(forKey: "LoginType") {
            switch loginType {
            case "LOGIN_APPLE":
                appleLoginManager.logout()
                print("애플 로그아웃 완료")
                // 애플 로그아웃 후 UI 업데이트 등 필요한 추가 작업 수행

            case "LOGIN_KAKAO":
                kakaoLoginManager.logout { success in
                    if success {
                        print("카카오 로그아웃 완료")
                        // 카카오 로그아웃 후 UI 업데이트 등 필요한 추가 작업 수행
                    } else {
                        print("카카오 로그아웃 실패")
                    }
                }

            default:
                print("알 수 없는 로그인 타입입니다.")
            }
        } else {
            print("로그인 타입이 UserDefaults에 저장되어 있지 않습니다.")
        }
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // 선택한 비율 중 작은 비율을 사용하여 크기 조정
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // 새로운 이미지 생성
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
