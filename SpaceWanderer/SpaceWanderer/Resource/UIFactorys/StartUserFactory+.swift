//
//  StartUserFactory+.swift
//  BubblyToDo
//
//  Created by 밀가루 on 9/25/24.
//

import UIKit
import Then

// 전체 padding
class PaddedTextField: UITextField {
    var padding: CGFloat = 0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
}

// horizontal padding
class HorizontalPaddedTextField: UITextField {
    var horizontalPadding: CGFloat = 8 // 좌우 패딩값
    var verticalPadding: CGFloat = 0 // 상하 패딩값

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }
}

// vertical padding
class VerticalPaddedTextField: UITextField {
    var verticalPadding: CGFloat = 8 // 상하 패딩값
    var horizontalPadding: CGFloat = 0 // 좌우 패딩값

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }
}

// left/right padding
class CustomPaddedTextField: UITextField {
    var leftPadding: CGFloat = 8 // 왼쪽 패딩값
    var rightPadding: CGFloat = 8 // 오른쪽 패딩값
    var verticalPadding: CGFloat = 0 // 상하 패딩값

    // 텍스트 표시 영역
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: leftPadding, dy: verticalPadding)
    }

    // 편집 중 텍스트 표시 영역
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: leftPadding, dy: verticalPadding)
    }

    // 플레이스홀더 표시 영역
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: leftPadding, dy: verticalPadding)
    }

    // 오른쪽 여백을 설정
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.rightViewRect(forBounds: bounds)
        return CGRect(x: rect.origin.x - rightPadding, y: rect.origin.y, width: rect.width, height: rect.height)
    }
}

class StartUserFactory {
    static func userTextField(placeholder: String?, textColor: UIColor, font: UIFont, backgroundColor: UIColor, cornerRadius: CGFloat, leftPadding: CGFloat, rightPadding: CGFloat) -> UITextField {
        return CustomPaddedTextField().then {
            $0.placeholder = placeholder
            $0.textColor = textColor
            $0.font = font
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
            $0.leftPadding = leftPadding
            $0.rightPadding = rightPadding
            $0.clearButtonMode = .whileEditing // 기본 클리어 버튼 활성화
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
        }
    }
    
    static func passwordTextField(placeholder: String?, textColor: UIColor, font: UIFont, backgroundColor: UIColor, cornerRadius: CGFloat, isSecure: Bool, leftPadding: CGFloat, rightPadding: CGFloat) -> UITextField {
        return CustomPaddedTextField().then {
            $0.placeholder = placeholder
            $0.textColor = textColor
            $0.font = font
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
            $0.isSecureTextEntry = isSecure // 비밀번호 입력 여부 설정
            $0.leftPadding = leftPadding
            $0.rightPadding = rightPadding
            $0.clearButtonMode = .whileEditing // 기본 클리어 버튼 활성화
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
        }
    }
}
