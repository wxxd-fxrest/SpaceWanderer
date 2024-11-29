//
//  AuthAPIManager.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class AuthAPIManager {
    static let shared = AuthAPIManager()
    
    lazy var backendURL: String = {
        if let path = Bundle.main.path(forResource: "SpaceInfo", ofType: "plist"),
           let spaceDict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let backendURL = spaceDict["AUTH_BASE_URL"] as? String {
            print("AUTH_BASE_URL", backendURL)
            return backendURL
        } else {
            print("Backend URL을 가져올 수 없습니다. 기본값 사용.")
            return "http://localhost:1020"
        }
    }()
    
    private init() {}

    func deleteUserAccount(userIdentifier: String, accessToken: String?, completion: @escaping (Bool, String) -> Void) {
        print("deleteUserAccount userIdentifier: ", userIdentifier)
        guard let url = URL(string: "\(backendURL)/apple-delete/\(userIdentifier)") else {
            completion(false, "잘못된 URL입니다.")
            return
        }
        
        var request = URLRequest(url: url)
        print("deleteUserAccount url: ", url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = ["userIdentifier": userIdentifier]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, "서버와의 연결에 실패했습니다: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, "서버 응답을 받지 못했습니다.")
                }
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("서버 응답: \(responseString)")
                
                if responseString.contains("회원 탈퇴가 완료되었습니다.") {
                    DispatchQueue.main.async {
                        completion(true, responseString)
                    }
                } else {
                    let errorMessage = "서버에서 예상치 못한 응답을 받았습니다: \(responseString)"
                    DispatchQueue.main.async {
                        completion(false, errorMessage)
                    }
                }
            }
        }
        
        task.resume()
    }
}
