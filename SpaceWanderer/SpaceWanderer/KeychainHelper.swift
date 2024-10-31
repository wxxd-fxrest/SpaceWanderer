//
//  KeychainHelper.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 10/31/24.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()

    func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else {
            print("Error: 값을 데이터로 변환할 수 없습니다.")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // 기존 값이 있으면 삭제하고 새로운 값 저장
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }

    // 키체인에서 값 삭제
    func deleteValue(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("Successfully deleted value for key: \(key)")
        } else {
            print("Failed to delete value from keychain: \(status)")
        }
    }
    
    // Keychain에서 데이터 출력하는 메서드
    func printValue(for key: String) -> String? {
        if let value = load(key: key) {
            print("Keychain Value for \(key): \(value)")
            return value
        } else {
            print("No value found in Keychain for key: \(key)")
            return nil
        }
    }
}
