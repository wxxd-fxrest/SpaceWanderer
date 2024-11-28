//
//  LoginView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/24/24.
//

import UIKit
import SnapKit

class LoginView: UIView {
    
    var appleSignInButton: UIButton!
    var kakaoLoginButton: UIButton!
    
    var appleSignInButtonTapped: (() -> Void)?
    var kakaoLoginButtonTapped: (() -> Void)?
    
    var loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.color = SpecialColors.WhiteColor
        $0.hidesWhenStopped = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        let buttonHeight: CGFloat = 50
        let iconSize: CGFloat = buttonHeight * 0.5
        let iconLeftMargin: CGFloat = 12
        let textLeftInset: CGFloat = iconLeftMargin + iconSize - 8
        
        let centerImage = UIFactory.makeImageView(imageName: "hangOnAlien")
        
        let appleSignInIcon = UIFactory.makeImageView(imageName: "apple.logo", color: .black)
        appleSignInButton = UIFactory.makeLoginButton(
            title: "Sign in with Apple",
            titleColor: .black,
            font: UIFont.systemFont(ofSize: 16),
            backgroundColor: .white,
            cornerRadius: 12,
            imagePadding: textLeftInset
        )
        
        let kakaoLoginIcon = UIFactory.makeImageView(imageName: "KakaoLogo")
        kakaoLoginButton = UIFactory.makeLoginButton(
            title: "카카오 로그인",
            titleColor: .black.withAlphaComponent(0.85),
            font: UIFont.boldSystemFont(ofSize: 16),
            backgroundColor: SpecialColors.KakaoButtonBackgroundColor,
            cornerRadius: 12,
            imagePadding: textLeftInset
        )
                
        kakaoLoginButton.addSubviews(kakaoLoginIcon)
        appleSignInButton.addSubviews(appleSignInIcon)
        addSubviews(centerImage, loadingIndicator, kakaoLoginButton, appleSignInButton)
        
        centerImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(loadingIndicator.snp.top).offset(-14)
            $0.width.height.equalTo(260)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(kakaoLoginButton.snp.top).offset(-26)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(snp.centerY).offset(120)
            $0.width.greaterThanOrEqualTo(260)
            $0.height.equalTo(buttonHeight)
        }
        
        kakaoLoginIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(kakaoLoginButton.snp.left).offset(iconLeftMargin)
            $0.width.height.equalTo(iconSize)
        }
        
        appleSignInButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(20)
            $0.width.greaterThanOrEqualTo(260)
            $0.height.equalTo(buttonHeight)
        }
        
        appleSignInIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(appleSignInButton.snp.left).offset(iconLeftMargin)
            $0.width.height.equalTo(iconSize)
        }
        
        // button target event
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
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
    
    // 로그인 버튼 숨기기
    func hideLoginButtons() {
        kakaoLoginButton.isHidden = true
        appleSignInButton.isHidden = true
    }
    
    // 로그인 버튼 보이기
    func showLoginButtons() {
        kakaoLoginButton.isHidden = false
        appleSignInButton.isHidden = false
    }
    
    @objc private func handleAppleSignIn() {
        appleSignInButtonTapped?()
    }
    
    @objc private func handleKakaoLogin() {
        kakaoLoginButtonTapped?()
    }
}
