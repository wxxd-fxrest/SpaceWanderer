package com.spacewanderer.space_back.controller;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.service.AppleService;

import net.minidev.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.text.ParseException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/auth/oauth2")
public class AppleController {
    @Autowired
    private AppleService appleService;

    @PostMapping("/apple-login")
    public String appleLogin(@RequestBody Map<String, String> body) throws ParseException {
        String idToken = body.get("idToken");
        String appleResponse = body.get("appleResponse"); // 애플 응답 가져오기
    
        if (idToken == null || idToken.isEmpty()) {
            throw new IllegalArgumentException("idToken cannot be null or empty");
        }
        if (appleResponse == null || appleResponse.isEmpty()) {
            throw new IllegalArgumentException("appleResponse cannot be null or empty");
        }
    
        // 서버에서 idToken 검증 및 사용자 정보 조회
        Map<String, String> loginResult = appleService.handleAppleLogin(idToken, appleResponse);
    
        // 결과에서 userIdentifier 및 userUniqueId 추출
        String userIdentifier = loginResult.get("userIdentifier");
        String userUniqueId = loginResult.get("userUniqueId");

        if (userIdentifier == null) {
            throw new RuntimeException("User Identifier cannot be null");
        }
        if (userUniqueId == null) {
            throw new RuntimeException("User Unique ID cannot be null");
        }
    
        // JSONObject 생성
        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("userIdentifier", userIdentifier);
        jsonResponse.put("userUniqueId", userUniqueId); // userUniqueId 추가

        // 클라이언트에 userIdentifier 반환
        return jsonResponse.toString();
    }
    
    @PostMapping("/auto-login")
    public ResponseEntity<Map<String, String>> autoLogin(@RequestBody Map<String, String> body) {
        try {
            String userIdentifier = body.get("userIdentifier");

            if (userIdentifier == null || userIdentifier.isEmpty()) {
                return ResponseEntity.badRequest().body(Collections.singletonMap("error", "userIdentifier is required"));
            }

            Optional<UserEntity> userEntity = appleService.findUserByUserIdentifier(userIdentifier);
            System.out.println("PostMapping userEntity |" + userEntity);

            if (userEntity.isPresent()) {
                String encryptedRefreshToken = userEntity.get().getRefreshToken();
                System.out.println("PostMapping encryptedRefreshToken |" + encryptedRefreshToken);
                
                String refreshToken = appleService.decryptRefreshToken(encryptedRefreshToken);
                System.out.println("PostMapping refreshToken |" + refreshToken);
                
                try {
                    String accessToken = appleService.getAccessTokenUsingRefreshToken(refreshToken);
                    System.out.println("PostMapping accessToken 1| " + accessToken);
                    
                    Map<String, String> response = new HashMap<>();
                    response.put("accessToken", accessToken); // Access Token 추가
                    response.put("userUniqueId", userEntity.get().getUserUniqueId()); // userUniqueId 추가
                    return ResponseEntity.ok(response);
                } catch (Exception e) { // 일반적인 예외로 변경
                    System.out.println("리프레시 토큰 처리 중 오류 발생: " + e.getMessage());
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Collections.singletonMap("error", "Invalid refresh token or another error"));
                }                
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Collections.singletonMap("error", "User not found"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Collections.singletonMap("error", e.getMessage()));
        }
    }
}