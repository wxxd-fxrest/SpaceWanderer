//
//  UIFactory+.swift
//  BubblyToDo
//
//  Created by 밀가루 on 9/25/24.
//

import UIKit
import Then
import SnapKit

class UIFactory: UIViewController {
    // MARK: View
    static func makeView(backgroundColor: UIColor, cornerRadius: CGFloat = 0) -> UIView {
        return UIView().then {
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
        }
    }
    
    // MARK: Stack View
    static func makeStackView(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        return UIStackView(arrangedSubviews: arrangedSubviews).then {
            $0.axis = axis
            $0.spacing = spacing
            $0.alignment = alignment
            $0.distribution = distribution
        }
    }
    
    // MARK: Label
    static func makeLabel(text: String, textColor: UIColor, font: UIFont, textAlignment: NSTextAlignment = .left) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.textColor = textColor
            $0.font = font
            $0.textAlignment = textAlignment
        }
    }
    
    // MARK: Button
    static func makeButton(title: String, titleColor: UIColor, font: UIFont, backgroundColor: UIColor, cornerRadius: CGFloat = 0
    ) -> UIButton {
        return UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = font
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
        }
    }
    
    static func makeLoginButton(title: String, titleColor: UIColor, font: UIFont, backgroundColor: UIColor, cornerRadius: CGFloat = 0, imagePadding: CGFloat = 0) -> UIButton {
        let button = UIButton(type: .system)
        
        // UIButton.Configuration 설정
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = titleColor // 텍스트 색상
        config.imagePadding = imagePadding      // 이미지와 텍스트 간격
        config.background.backgroundColor = backgroundColor
        config.background.cornerRadius = cornerRadius
        
        button.configuration = config
        button.titleLabel?.font = font // 폰트 설정

        return button
    }

    
//    static func makeButton(title: String, titleColor: UIColor, font: UIFont, backgroundColor: UIColor, cornerRadius: CGFloat = 0, image: UIImage?) -> UIButton {
//        return UIButton().then {
//            $0.setTitle(title, for: .normal)
//            $0.setTitleColor(titleColor, for: .normal)
//            if let image = image {
//                $0.setImage(image, for: .normal)
//            }
//            $0.titleLabel?.font = font
//            $0.backgroundColor = backgroundColor
//            $0.layer.cornerRadius = cornerRadius
//            $0.clipsToBounds = true
//        }
//    }
    
    // MARK: Image Button
    static func makeSystemImageButton(image: String, tintColor: UIColor) -> UIButton {
        return UIButton().then {
            $0.setImage(UIImage(systemName: image), for: .normal)
            $0.tintColor = tintColor
        }
    }
    
    static func makeImageButton(image: String, target: Any?, action: Selector, width: CGFloat, height: CGFloat) -> UIButton {
        let button = UIButton().then {
            $0.setImage(UIImage(named: image)?.withRenderingMode(.alwaysOriginal), for: .normal)
            $0.addTarget(target, action: action, for: .touchUpInside)
            $0.backgroundColor = .clear
            $0.contentMode = .scaleAspectFit
        }
        
        button.snp.makeConstraints {
            $0.width.equalTo(width)
            $0.height.equalTo(height)
//            $0.height.equalTo(button.snp.width).multipliedBy((UIImage(named: image)?.size.height ?? 1) / (UIImage(named: image)?.size.width ?? 1)) // 이미지의 비율에 맞춰 높이 조절
        }
        
        return button
    }
    
    // MARK: Image
    static func makeImageView(imageName: String, contentMode: UIView.ContentMode = .scaleAspectFit, color: UIColor? = nil) -> UIImageView {
        return UIImageView().then {
            if let systemImage = UIImage(systemName: imageName) {
                $0.image = systemImage // 시스템 이미지 설정
                if let tintColor = color {
                    $0.tintColor = tintColor // tintColor 설정
                }
            } else if let assetImage = UIImage(named: imageName) {
                $0.image = assetImage // Assets 이미지 설정
            } else {
                $0.image = nil // 이미지 이름이 유효하지 않을 경우
            }
            $0.contentMode = contentMode
            $0.clipsToBounds = true
        }
    }
    
    // MARK: CollectionView
    static func makeCollectionView(layout: UICollectionViewLayout, scrollDirection: UICollectionView.ScrollDirection) -> UICollectionView {
        // layout을 사용하는 경우 layout의 scrollDirection을 설정
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = scrollDirection
        }
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
    }
}
