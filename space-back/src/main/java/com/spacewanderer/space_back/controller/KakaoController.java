package com.spacewanderer.space_back.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;
import com.spacewanderer.space_back.service.KakaoService;
import com.spacewanderer.space_back.utils.EncryptionUtil;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth/oauth2")
@RequiredArgsConstructor
public class KakaoController {
    private final KakaoService kakaoService;
    private final UserRepository userRepository; 
    private final EncryptionUtil encryptionUtil; 

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
            
            // 리프레시 토큰 복호화
            String decryptedRefreshToken;
            try {
                decryptedRefreshToken = encryptionUtil.decrypt(userEntity.getRefreshToken());
                response.put("refreshToken", decryptedRefreshToken); // 복호화된 리프레시 토큰을 응답에 포함
            } catch (Exception e) {
                throw new RuntimeException("리프레시 토큰 복호화에 실패했습니다.", e);
            }
            
            // 나머지 사용자 데이터
            response.put("nickname", userEntity.getNickname());
            response.put("email", userEntity.getEmail());
            response.put("userUniqueId", userEntity.getUserUniqueId()); // userUniqueId 추가
            System.out.println("유니크 아이디: " + userEntity.getUserUniqueId());

            // 필요한 다른 필드 추가
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }
 
    @DeleteMapping("/kakao-delete/{userIdentifier}")
    public ResponseEntity<String> deleteUser(@PathVariable("userIdentifier") String userIdentifier) {

        try {
            kakaoService.deleteKakaoAccount(userIdentifier);
            return ResponseEntity.ok("회원 탈퇴가 완료되었습니다.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("회원 탈퇴에 실패했습니다: " + e.getMessage());
        }
    }    
}
