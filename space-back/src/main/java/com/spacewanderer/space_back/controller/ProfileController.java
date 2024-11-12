package com.spacewanderer.space_back.controller;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.entity.UserEntity;
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

    // 프로필 조회
    @GetMapping("/{userIdentifier}")
    public ResponseEntity<UserEntity> getUserById(@PathVariable("userIdentifier") String userIdentifier) {
        return userRepository.findByUserIdentifier(userIdentifier)
        .map(user -> {
            // 사용자 정보를 출력
            System.out.println("사용자 ID: " + user.getUserIdentifier());
            System.out.println("이메일: " + user.getEmail());
            System.out.println("닉네임: " + user.getNickname());
            System.out.println("생일: " + user.getBirthDay());
            System.out.println("거주 행성: " + user.getInhabitedPlanet());
            System.out.println("프로필 이미지: " + user.getProfileImage());
            System.out.println("리프레시 토큰: " + user.getRefreshToken());
            System.out.println("로그인 타입: " + user.getLoginType());
            System.out.println("목표 일 수: " + user.getDayGoalCount());
            System.out.println("목적지 행성: " + user.getDestinationPlanet());

            return ResponseEntity.ok(user);
        })
        .orElse(ResponseEntity.notFound().build());
    }

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

    // 목표행성 업데이트 
    @PutMapping("/update-planet/{userIdentifier}")
    public ResponseEntity<Void> updatePlanet(@PathVariable("userIdentifier") String userIdentifier, @RequestBody Map<String, String> requestBody) {
        String destinationPlanet = requestBody.get("destinationPlanet"); // 행성 이름 가져오기

        // userId를 통해 사용자를 검색
        UserEntity userEntity = userRepository.findByUserIdentifier(userIdentifier)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userIdentifier));
        
        // 행성 이름 업데이트
        userEntity.setDestinationPlanet(destinationPlanet);
        
        // 변경 사항 저장
        userRepository.save(userEntity);
        
        return ResponseEntity.ok().build(); // 성공적인 응답 반환
    }
}
