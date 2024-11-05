//
//  UserTextField+.swift
//  BubblyToDo
//
//  Created by 밀가루 on 9/16/24.
//

import UIKit

class UserTextFieldFactory {
    
    static func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.isSecureTextEntry = isSecure // 비밀번호 필드 여부 설정
        return textField
    }
    
    static func createEmailTextField() -> UITextField {
        return createTextField(placeholder: "이메일을 입력해 주세요.")
    }
    
    static func createUsernameTextField() -> UITextField {
        return createTextField(placeholder: "닉네임을 입력해 주세요.")
    }
    
    static func createPasswordTextField() -> UITextField {
        return createTextField(placeholder: "비밀번호를 입력해 주세요.", isSecure: true) // 비밀번호 필드로 설정
    }
    
    static func createCheckPasswordTextField() -> UITextField {
        return createTextField(placeholder: "비밀번호를 확인해 주세요.", isSecure: true) // 비밀번호 확인 필드로 설정
    }
}
