package com.spacewanderer.space_back.controller;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.repository.UserRepository;
import com.spacewanderer.space_back.service.UserService;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class ProfileController {
    
    private final UserRepository userRepository;
    private final UserService userService;

    // 프로필 업데이트
    @PutMapping("/profile-update/{userIdentifier}")
    public ResponseEntity<String> updateProfile(@PathVariable("userIdentifier") String userIdentifier, @RequestBody Map<String, Object> updates) {
        System.out.println("userIdentifier에 대한 프로필 업데이트 시작: " + userIdentifier);

        // 사용자 찾기
        return userRepository.findByUserIdentifier(userIdentifier)
            .map(user -> {
                // 요청 데이터에 따라 프로필 업데이트
                updates.forEach((key, value) -> {
                    switch (key) {
                        case "nickname":
                            user.setNickname((String) value);
                            break;
                        case "birthDay":
                            user.setBirthDay((String) value);
                            break;
                        case "inhabitedPlanet":
                            user.setInhabitedPlanet((String) value);
                            break;
                        case "profileImage":
                            user.setProfileImage((String) value);
                            break;
                    }
                });

                // 업데이트된 사용자 객체 저장
                userRepository.save(user);
                return ResponseEntity.ok("프로필이 업데이트되었습니다.");
            })
            .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found"));
    }

    // 닉네임 중복 체크
    @GetMapping("/check-nickname/{nickname}")
    public ResponseEntity<Boolean> checkNickname(@PathVariable("nickname") String nickname) {
        boolean isUnique = userService.isNicknameUnique(nickname);
        return ResponseEntity.ok(isUnique); // true/false 값 그대로 반환
    }    
}
