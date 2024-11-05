package com.spacewanderer.space_back.controller;

import java.text.ParseException;
import java.util.Map;
import java.util.Optional;
import java.util.Collections;
import java.util.HashMap;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;
import com.spacewanderer.space_back.service.AppleService;

import lombok.RequiredArgsConstructor;
import net.minidev.json.JSONObject;

@RestController
@RequestMapping("/api/v1/auth/oauth2")
@RequiredArgsConstructor
public class AppleController {
    private final AppleService appleService;
    private final UserRepository userRepository; 

    // function: Apple Login PostMapping 
    @PostMapping("/apple-login")
    public String appleLogin(@RequestBody Map<String, String> body) throws ParseException {
        String idToken = body.get("idToken");
        String appleResponse = body.get("appleResponse"); 

        if(idToken == null || idToken.isEmpty()) {
            throw new IllegalArgumentException("idToken이 null이거나 비어있습니다.");
        }
        
        if(appleResponse == null || appleResponse.isEmpty()) {
            throw new IllegalArgumentException("appleResponse이 null이거나 비어있습니다.");
        }

        // function: Apple Login 요청 처리 
        Map<String, String> loginResult = appleService.handleAppleLogin(idToken, appleResponse);

        String userIdentifier = loginResult.get("userIdentifier");
        String userUniqueId = loginResult.get("userUniqueId");

        if(userIdentifier == null) {;
            throw new RuntimeException("userIdentifier가 null 입니다.");
        }

        if(userUniqueId == null) {;
            throw new RuntimeException("userUniqueId가 null 입니다.");
        }

        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("userIdentifier", userIdentifier);
        jsonResponse.put("userUniqueId", userUniqueId);

        return jsonResponse.toString();
    }

    // function: Auto Apple Login PostMapping 
    @PostMapping("/auto-login")
    public ResponseEntity<Map<String, String>> autoLogin(@RequestBody Map<String, String> body) {
        try {
            String userIdentifier = body.get("userIdentifier");

            if(userIdentifier == null || userIdentifier.isEmpty()) {
                return ResponseEntity.badRequest().body(Collections.singletonMap("error", "userIdentifier is required"));
            }

            Optional<UserEntity> userEntity = userRepository.findByUserIdentifier(userIdentifier);
            
            if(userEntity.isPresent()) {
                String encryptedRefreshToken = userEntity.get().getRefreshToken();
                String refreshToken = appleService.decryptRefreshToken(encryptedRefreshToken);
                
                try {
                    String accessToken = appleService.getAccessTokenUsingRefreshToken(refreshToken);
                    
                    Map<String, String> response = new HashMap<>();
                    response.put("accessToken", accessToken); // Access Token 추가
                    response.put("userUniqueId", userEntity.get().getUserUniqueId()); // userUniqueId 추가
                    response.put("nickname", userEntity.get().getNickname());

                    return ResponseEntity.ok(response);
                } catch(Exception e) {
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Collections.singletonMap("error", "Invalid refresh token or another error"));
                }
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Collections.singletonMap("error", e.getMessage()));
        }
        
        return null;
    }
}