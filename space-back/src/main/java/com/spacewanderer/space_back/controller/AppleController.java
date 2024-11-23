package com.spacewanderer.space_back.controller;

import java.text.ParseException;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.dto.request.apple.AppleAutoLoginRequestDTO;
import com.spacewanderer.space_back.dto.request.apple.AppleLoginRequestDTO;
import com.spacewanderer.space_back.dto.response.AppleAutoLoginResponseDTO;
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
    public String appleLogin(@RequestBody AppleLoginRequestDTO request) throws ParseException {
        String idToken = request.getIdToken();
        String appleResponse = request.getAppleResponse();
        String deviceToken = request.getDeviceToken();

        if(idToken == null || idToken.isEmpty()) {
            throw new IllegalArgumentException("idToken이 null이거나 비어있습니다.");
        }

        if(appleResponse == null || appleResponse.isEmpty()) {
            throw new IllegalArgumentException("appleResponse이 null이거나 비어있습니다.");
        }

        // Apple 로그인 요청 처리
        Map<String, String> loginResult = appleService.handleAppleLogin(idToken, appleResponse, deviceToken);

        String userIdentifier = loginResult.get("userIdentifier");
        String userUniqueId = loginResult.get("userUniqueId");

        if(userIdentifier == null) {
            throw new RuntimeException("userIdentifier가 null 입니다.");
        }

        if(userUniqueId == null) {
            throw new RuntimeException("userUniqueId가 null 입니다.");
        }

        JSONObject jsonResponse = new JSONObject();
        jsonResponse.put("userIdentifier", userIdentifier);
        jsonResponse.put("userUniqueId", userUniqueId);

        return jsonResponse.toString();
    }

    // function: Auto Apple Login PostMapping 
    @PostMapping("/apple-auto-login")
    public ResponseEntity<AppleAutoLoginResponseDTO> autoLogin(@RequestBody AppleAutoLoginRequestDTO request) {
        try {
            String userIdentifier = request.getUserIdentifier();

            if(userIdentifier == null || userIdentifier.isEmpty()) {
                return ResponseEntity.badRequest().body(new AppleAutoLoginResponseDTO("error", null, null));
            }

            Optional<UserEntity> userEntity = userRepository.findByUserIdentifier(userIdentifier);

            if(userEntity.isPresent()) {
                String encryptedRefreshToken = userEntity.get().getRefreshToken();
                String refreshToken = appleService.decryptRefreshToken(encryptedRefreshToken);

                try {
                    String accessToken = appleService.getAccessTokenUsingRefreshToken(refreshToken);

                    AppleAutoLoginResponseDTO response = new AppleAutoLoginResponseDTO(accessToken, userEntity.get().getUserUniqueId(), userEntity.get().getNickname());

                    return ResponseEntity.ok(response);
                } catch(Exception e) {
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new AppleAutoLoginResponseDTO("error", null, null));
                }
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new AppleAutoLoginResponseDTO("error", null, null));
        }

        return null;
    }

    // function: 회원 탈퇴 API
    @DeleteMapping("/apple-delete/{userIdentifier}")
    public ResponseEntity<String> deleteUser(@PathVariable("userIdentifier") String userIdentifier) {
        try {
            appleService.deleteUserAccount(userIdentifier);  // 서비스 호출
            return ResponseEntity.ok("회원 탈퇴가 완료되었습니다.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("회원 탈퇴에 실패했습니다: " + e.getMessage());
        }
    }    
}