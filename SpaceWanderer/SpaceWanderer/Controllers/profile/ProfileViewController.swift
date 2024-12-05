//
//  ProfileViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/5/24.
//

import UIKit
import Photos

class ProfileViewController: UIViewController {
    var userUniqueId: String?
    var userIdentifier: String?
    
    let kakaoLoginManager = KakaoLoginAPIManager() // KakaoLoginManager 인스턴스 생성
    let appleLoginManager = AppleAPILoginManager() // AppleLoginManager 인스턴스 생성
    
    private let profileView = ProfileView() // ProfileView 인스턴스

    // properties
    var id: String?
    var nickname: String?
    var origin: String?
    var birthday: String?
    var profileImage: String?
    var location: String?
    var totalGoals: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        
        // Setup Profile View
        setupProfileView()
        
        profileView.downloadIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadIconTapped)))
        profileView.moreIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreIconTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        setUpdateProfileUI()
        
        print("Profile nickname: ", nickname ?? "No nickname")
        print("Profile origin: ", origin ?? "No origin")
        print("Profile image: ", profileImage ?? "No profile image")
    }
    
    func setUpdateProfileUI() {
        DispatchQueue.main.async {
            self.profileView.nameLabel.text = self.nickname
            self.profileView.idLabel.text = self.id
            self.profileView.originLabel.text = self.origin
            self.profileView.birthdayLabel.text = self.birthday
            self.profileView.profileImageView.image = UIImage(named: self.profileImage ?? "LaunchScreenIcon")
            self.profileView.locationLabel.text = self.location
            self.profileView.starLabel.text = self.totalGoals
            self.profileView.totalStepsLabel.text = self.totalGoals
        }
    }
    
    private func setupProfileView() {
        view.addSubview(profileView)
        profileView.frame = view.bounds // Fill the view
    }
    
    func captureCardViewAsImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: profileView.cardView.bounds.size)
        return renderer.image { context in
            profileView.cardView.layer.render(in: context.cgContext)
        }
    }

    func saveAndShareImage() {
        guard let image = captureCardViewAsImage() else { return }

        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            case .denied, .restricted:
                print("Access to the photo library was denied.")
            case .notDetermined:
                print("Requested access to the photo library.")
            @unknown default:
                fatalError()
            }
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Failed to save image: \(error.localizedDescription)")
        } else {
            print("Image saved to the photo library.")
        }
    }
    
    @objc private func downloadIconTapped() {
        print("Download Icon Tapped")
        saveAndShareImage()
    }

    @objc private func moreIconTapped() {
        print("More Icon Tapped")
        
        // UIAlertController 생성
        let alertController = UIAlertController(title: "선택", message: "원하는 작업을 선택하세요.", preferredStyle: .actionSheet)
        
        // 옵션 1: 프로필 수정 페이지로 이동
        let option1 = UIAlertAction(title: "프로필 수정", style: .default) { _ in
            print("프로필 수정 선택됨")
            // 프로필 수정 화면으로 이동
            if let navigationController = self.navigationController {
                let profileEditVC = ProfileEditViewController()  // 프로필 수정 화면을 나타내는 뷰 컨트롤러
                profileEditVC.userIdentifier = self.userIdentifier
                profileEditVC.previousNickname = self.nickname
                profileEditVC.previousProfileImage = self.profileImage
                profileEditVC.previousOrigin = self.origin
                profileEditVC.hidesBottomBarWhenPushed = true // 탭 바 숨기기
                navigationController.pushViewController(profileEditVC, animated: true)
            }
        }
        
        // 옵션 2: 설정 페이지로 이동
        let option2 = UIAlertAction(title: "설정", style: .default) { _ in
            print("설정 선택됨")
            // 설정 화면으로 이동
            if let navigationController = self.navigationController {
                let settingsVC = SettingViewController()  // 설정 화면을 나타내는 뷰 컨트롤러
                settingsVC.userIdentifier = self.userIdentifier
                settingsVC.hidesBottomBarWhenPushed = true // 탭 바 숨기기
                navigationController.pushViewController(settingsVC, animated: true)
            }
        }
        
        // 취소 버튼
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("취소 버튼 눌림")
        }
        
        // 각 옵션을 UIAlertController에 추가
        alertController.addAction(option1)
        alertController.addAction(option2)
        alertController.addAction(cancelAction)
        
        // 모달 표시
        present(alertController, animated: true, completion: nil)
    }
}
