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
    
    let kakaoLoginManager = KakaoLoginManager() // KakaoLoginManager 인스턴스 생성
    let appleLoginManager = AppleLoginManager() // AppleLoginManager 인스턴스 생성
    
    // header
    let titleLabel = UILabel()
    let downloadIcon = UIImageView(image: UIImage(named: "DownloadIcon"))
    let moreIcon = UIImageView(image: UIImage(named: "MoreVerticalIcon"))
    
    // 아이콘들을 포함할 스택 뷰
    var iconsStackView: UIStackView!
    var combinedStackView: UIStackView!
    
    // profile card
    let cardView = UIView()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let idLabel = UILabel()
    let originLabel = UILabel()
    let birthdayLabel = UILabel()
    let descriptionLabel = UILabel()
    let starView = UIView()
    let starStackView = UIStackView()
    let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
    let starLabel = UILabel()
    
    // etc
    let locationTitleLabel = UILabel()
    let locationLabel = UILabel()

    let totalStepsTitleLabel = UILabel()
    let totalStepsLabel = UILabel()
    
    // 로딩 인디케이터
    var loadingIndicator: UIActivityIndicatorView!
    
    // label & profile image
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
        
        setupLoadingIndicator()
        
        setupStackView()
        setupProfileCard()
        setupETCStack()
        
        print("profile nickname: ", nickname)
        print("profile origin: ", origin)
        print("profile location: ", location)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // 유저 데이터 가져오기
//        fetchUserData()
        nameLabel.text = nickname
        idLabel.text = id
        originLabel.text = origin
        birthdayLabel.text = birthday
        profileImageView.image = UIImage(named: profileImage ?? "LaunchScreenIcon")
        locationLabel.text = location
        starLabel.text = totalGoals
        totalStepsLabel.text = totalGoals
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = view.center
        loadingIndicator.color = .orange
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
//    private func fetchUserData() {
//        let userManager = UserManager()
//
//        guard let userIdentifier = userIdentifier else {
//            print("userIdentifier가 nil입니다.")
//            return
//        }
//                
//        // 로딩 인디케이터 시작
//        loadingIndicator.startAnimating()
//        
//        userManager.getUser(by: userIdentifier) { result in
//            DispatchQueue.main.async {
//                // 로딩 인디케이터 중지
//                self.loadingIndicator.stopAnimating()
//            }
//            
//            switch result {
//            case .success(let userEntity):
//                DispatchQueue.main.async {
//                    // 사용자 정보를 UI에 업데이트
//                    print("사용자 ID: \(userEntity.userIdentifier)")
//                    print("userEntity:", userEntity)
//                    // 목적지 업데이트
//                    self.nickname = userEntity.nickname ?? "정보 없음" // destinationPlanet 업데이트
//                    self.id = "#\(userEntity.userUniqueId ?? "정보 없음")"
//                    self.origin = "출신 · \(userEntity.inhabitedPlanet ?? "정보 없음")"
//                    self.birthday = "생일 · \(userEntity.birthDay ?? "정보 없음")"
//                    self.profileImage = "\(userEntity.profileImage ?? "LaunchScreenIcon")"
//                    self.location = "\(userEntity.destinationPlanet ?? "정보 없음")"
//                    self.totalSteps = "\(userEntity.dayGoalCount ?? 0)"
//                    
//                    self.nameLabel.text = self.nickname
//                    self.idLabel.text = self.id
//                    self.originLabel.text = self.origin
//                    self.birthdayLabel.text = self.birthday
//                    self.profileImageView.image = UIImage(named: self.profileImage ?? "LaunchScreenIcon")
//                    self.locationLabel.text = self.location
//                    self.starLabel.text = self.totalSteps
//                    self.totalStepsLabel.text = self.totalSteps
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    // 오류 처리 (예: 경고 창 표시)
//                    print("사용자 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
    
    private func setupStackView() {
        // titleLabel 설정
        titleLabel.text = "PROFILE"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = SpecialColors.WhiteColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // downloadIcon 설정
        downloadIcon.tintColor = SpecialColors.WhiteColor
        downloadIcon.translatesAutoresizingMaskIntoConstraints = false
        downloadIcon.isUserInteractionEnabled = true // 클릭 가능하게 설정
        let downloadTapGesture = UITapGestureRecognizer(target: self, action: #selector(downloadIconTapped))
        downloadIcon.addGestureRecognizer(downloadTapGesture)
        
        // moreIcon 설정
        moreIcon.tintColor = SpecialColors.WhiteColor
        moreIcon.translatesAutoresizingMaskIntoConstraints = false
        moreIcon.isUserInteractionEnabled = true // 클릭 가능하게 설정
        let moreTapGesture = UITapGestureRecognizer(target: self, action: #selector(moreIconTapped))
        moreIcon.addGestureRecognizer(moreTapGesture)
        
        // downloadIcon과 moreIcon을 가로 스택으로 묶음
        iconsStackView = UIStackView(arrangedSubviews: [downloadIcon, moreIcon])
        iconsStackView.axis = .horizontal
        iconsStackView.spacing = 8
        iconsStackView.translatesAutoresizingMaskIntoConstraints = false
        iconsStackView.alignment = .fill
        iconsStackView.distribution = .fillProportionally // 아이콘들이 비례적으로 차지

        // titleLabel과 iconsStackView를 다시 가로 스택으로 묶음
        combinedStackView = UIStackView(arrangedSubviews: [titleLabel, iconsStackView])
        combinedStackView.axis = .horizontal
        combinedStackView.spacing = 16
        combinedStackView.translatesAutoresizingMaskIntoConstraints = false
        combinedStackView.alignment = .fill
        combinedStackView.distribution = .fillProportionally // 각 아이템이 비례적으로 차지

        // 부모 뷰에 추가
        view.addSubview(combinedStackView)

        // 레이아웃 제약 설정
        NSLayoutConstraint.activate([
            iconsStackView.widthAnchor.constraint(equalToConstant: 60),

            combinedStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            combinedStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            combinedStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func setupProfileCard() {
        // 카드 뷰 설정
        cardView.backgroundColor = SpecialColors.WhiteColor
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // 프로필 이미지 (원형으로 설정)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 40 // 반지름 설정 (원형)
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(profileImageView)
        
        // 이름 라벨
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // ID 라벨
        idLabel.font = UIFont.systemFont(ofSize: 14)
        idLabel.textColor = .darkGray
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 출신 정보 라벨
        originLabel.font = UIFont.systemFont(ofSize: 16)
        originLabel.textColor = .darkGray
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 생일 정보 라벨
        birthdayLabel.font = UIFont.systemFont(ofSize: 16)
        birthdayLabel.textColor = .darkGray
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 설명 라벨
        descriptionLabel.text = "위 외계인에게 우주 여행을 허가함."
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 가로 스택: nameLabel과 idLabel 포함
        let nameIdStackView = UIStackView(arrangedSubviews: [nameLabel, idLabel])
        nameIdStackView.axis = .horizontal
        nameIdStackView.alignment = .center  // 세로 정렬을 맞추기 위해 alignment를 .center로 설정
        nameIdStackView.spacing = 8
        nameIdStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 세로 스택: nameIdStackView, originLabel, birthdayLabel, descriptionLabel 포함
        let infoStackView = UIStackView(arrangedSubviews: [nameIdStackView, originLabel, birthdayLabel, descriptionLabel])
        infoStackView.axis = .vertical
        infoStackView.alignment = .leading
        infoStackView.spacing = 8
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(infoStackView)
        
        // 별(점수) 뷰
        starView.backgroundColor = SpecialColors.WhiteColor
        starView.layer.cornerRadius = 12
        starView.translatesAutoresizingMaskIntoConstraints = false

        // 그림자 설정
        starView.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        starView.layer.shadowOpacity = 0.3 // 그림자 불투명도
        starView.layer.shadowOffset = CGSize(width: 0, height: 2) // 그림자 위치
        starView.layer.shadowRadius = 2 // 그림자 퍼짐 정도
        cardView.addSubview(starView)

        
        // 아이콘 및 라벨을 담을 스택 뷰 생성
        starStackView.axis = .horizontal
        starStackView.alignment = .center
        starStackView.spacing = 4
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        starView.addSubview(starStackView)
        
        // 별 아이콘
        starIcon.tintColor = SpecialColors.GreenStarColor
        starIcon.contentMode = .scaleAspectFit
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        starStackView.addArrangedSubview(starIcon)
        
        // 점수 라벨
        starLabel.text = "36"
        starLabel.font = UIFont.boldSystemFont(ofSize: 14)
        starLabel.textColor = SpecialColors.GreenStarColor
        starLabel.translatesAutoresizingMaskIntoConstraints = false
        starStackView.addArrangedSubview(starLabel)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 카드 뷰
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.topAnchor.constraint(equalTo: combinedStackView.bottomAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // 프로필 이미지
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // 별(점수) 뷰 (프로필 이미지 하단 중앙에 배치)
            starView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            starView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -12), // 겹치도록 설정
            starView.widthAnchor.constraint(equalToConstant: 60),
            starView.heightAnchor.constraint(equalToConstant: 28),
            
            // 스택 뷰 (starLabel과 아이콘)
            starStackView.centerXAnchor.constraint(equalTo: starView.centerXAnchor),
            starStackView.centerYAnchor.constraint(equalTo: starView.centerYAnchor),
            
            // 정보 스택 뷰 (nameIdStackView 포함)
            infoStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            infoStackView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupETCStack() {
        locationTitleLabel.text = "현 위치"
        locationTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        locationTitleLabel.textColor = SpecialColors.WhiteColor
        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        locationLabel.text = "수성"
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.textColor = SpecialColors.WhiteColor
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalStepsTitleLabel.text = "만보 달성 횟수"
        totalStepsTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        totalStepsTitleLabel.textColor = SpecialColors.WhiteColor
        totalStepsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalStepsLabel.text = "36회"
        totalStepsLabel.font = UIFont.systemFont(ofSize: 16)
        totalStepsLabel.textColor = SpecialColors.WhiteColor
        totalStepsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // locationTitleLabel과 locationLabel 가로 스택
        let locationStackView = UIStackView(arrangedSubviews: [locationTitleLabel, locationLabel])
        locationStackView.axis = .horizontal
        locationStackView.spacing = 8
        locationStackView.translatesAutoresizingMaskIntoConstraints = false

        // totalStepsTitleLabel과 totalStepsLabel 가로 스택
        let totalStepsStackView = UIStackView(arrangedSubviews: [totalStepsTitleLabel, totalStepsLabel])
        totalStepsStackView.axis = .horizontal
        totalStepsStackView.spacing = 8
        totalStepsStackView.translatesAutoresizingMaskIntoConstraints = false

        // 두 가로 스택을 포함하는 세로 스택
        let combinedStackView = UIStackView(arrangedSubviews: [locationStackView, totalStepsStackView])
        combinedStackView.axis = .vertical
        combinedStackView.alignment = .fill
        combinedStackView.spacing = 16 // 세로 간격
        combinedStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 부모 뷰에 추가
        view.addSubview(combinedStackView)

        // 레이아웃 제약 설정
        NSLayoutConstraint.activate([
            combinedStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            combinedStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 28),
            combinedStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            combinedStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    // downloadIcon 클릭 시 호출될 메서드
    @objc private func downloadIconTapped() {
        print("Download Icon Tapped")
        saveAndShareImage()
    }

    // moreIcon 클릭 시 호출될 메서드
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
            // 취소 처리
        }
        
        // 각 옵션을 UIAlertController에 추가
        alertController.addAction(option1)
        alertController.addAction(option2)
        alertController.addAction(cancelAction)
        
        // 모달 표시
        present(alertController, animated: true, completion: nil)
    }
    
    // 1. 카드 뷰를 이미지로 변환하기
    func captureCardViewAsImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: cardView.bounds.size)
        return renderer.image { context in
            cardView.layer.render(in: context.cgContext)
        }
    }

    // 2. 이미지를 앨범에 저장하고 공유하기
    func saveAndShareImage() {
        guard let image = captureCardViewAsImage() else { return }

        // 사진 라이브러리에 접근 권한 요청
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                // 이미지를 앨범에 저장
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            case .denied, .restricted:
                print("앨범 접근이 거부되었습니다.")
            case .notDetermined:
                print("앨범 접근 권한을 요청했습니다.")
            @unknown default:
                fatalError()
            }
        }
    }
    
    // 3. 이미지 저장 결과 처리
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("이미지 저장 실패: \(error.localizedDescription)")
        } else {
            print("이미지가 앨범에 저장되었습니다.")
        }
    }
}
