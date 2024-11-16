package com.spacewanderer.space_back.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;
import com.spacewanderer.space_back.service.KakaoService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth/oauth2")
@RequiredArgsConstructor
public class KakaoController {
    private final KakaoService kakaoService;
    private final UserRepository userRepository; 

    @PostMapping("/kakao-login")
    public ResponseEntity<UserEntity> registerUser(@RequestBody UserEntity userEntity) {
        System.out.println("/kakao-login 1");
        
        UserEntity registeredUser = kakaoService.registerUser(
                userEntity.getUserIdentifier(),
                userEntity.getEmail(),
                userEntity.getRefreshToken(),
                userEntity.getLoginType(),
                userEntity.getDestinationPlanet(),
                userEntity.getDayGoalCount()
        );
        System.out.println("/kakao-login 2");
        System.out.println("registeredUser | " + registeredUser);
        return ResponseEntity.ok(registeredUser);
    }    

    @GetMapping("/get-kakao-user/{userIdentifier}")
    public ResponseEntity<Map<String, Object>> getUserData(@PathVariable("userIdentifier") String userIdentifier) {
        Optional<UserEntity> user = userRepository.findByUserIdentifier(userIdentifier);
        if (user.isPresent()) {
            UserEntity userEntity = user.get();
            Map<String, Object> response = new HashMap<>();
            response.put("refreshToken", userEntity.getRefreshToken());
            response.put("nickname", userEntity.getNickname());
            response.put("email", userEntity.getEmail());
            response.put("userUniqueId", userEntity.getUserUniqueId()); // userUniqueId 추가
            System.out.println("유니크 아이디" + userEntity.getUserUniqueId());

            // 필요한 다른 필드 추가
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }    

    @PostMapping("/get-kakao-access-token")
    public ResponseEntity<Map<String, String>> getAccessToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        String userIdentifier = request.get("userIdentifier");

        try {
            String accessToken = kakaoService.getAccessToken(refreshToken, userIdentifier);
            Map<String, String> response = new HashMap<>();
            response.put("access_token", accessToken);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            if (e.getMessage().equals("Refresh Token이 만료되었습니다.")) {
                Map<String, String> errorResponse = new HashMap<>();
                errorResponse.put("error", "Refresh Token이 만료되었습니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
            } else {
                throw e;
            }
        }
    }
}
