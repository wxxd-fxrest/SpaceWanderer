package com.spacewanderer.space_back.controller;

import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class ProfileController {
    
    private final UserRepository userRepository;

    @PutMapping("/profile-update/{userIdentifier}")
    public ResponseEntity<String> updateProfile(@PathVariable("userIdentifier") String userIdentifier, @RequestBody Map<String, Object> updates) {
        System.out.println("userIdentifier에 대한 프로필 업데이트 시작: " + userIdentifier);
        
        // userIdentifier로 사용자 검색
        Optional<UserEntity> optionalUser = userRepository.findByUserIdentifier(userIdentifier);
        
        // 사용자가 존재하지 않으면 404 Not Found 반환
        if (!optionalUser.isPresent()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }
    
        // 존재하는 사용자 객체 가져오기
        UserEntity user = optionalUser.get();
        System.out.println("Existing user: " + user);
        
        // 요청 데이터에 따라 필드 업데이트
        if (updates.containsKey("nickname")) {
            user.setNickname((String) updates.get("nickname"));
        }
        if (updates.containsKey("birthDay")) {
            user.setBirthDay((String) updates.get("birthDay"));
        }
        if (updates.containsKey("inhabitedPlanet")) {
            user.setInhabitedPlanet((String) updates.get("inhabitedPlanet"));
        }
        if (updates.containsKey("profileImage")) {
            user.setProfileImage((String) updates.get("profileImage"));
        }
    
        // 업데이트된 사용자 객체 저장
        userRepository.save(user);
        return ResponseEntity.ok("프로필이 업데이트되었습니다.");
    }    
}
