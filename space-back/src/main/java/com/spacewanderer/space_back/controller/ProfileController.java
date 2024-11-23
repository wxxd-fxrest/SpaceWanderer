package com.spacewanderer.space_back.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.dto.request.user.DestinationPlanetUpdateRequestDTO;
import com.spacewanderer.space_back.dto.request.user.UserUpdateRequestDTO;
import com.spacewanderer.space_back.dto.response.UserResponseDTO;
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

    // function: 프로필 조회
    @GetMapping("/{userIdentifier}")
    public ResponseEntity<UserResponseDTO> getUserById(@PathVariable("userIdentifier") String userIdentifier) {
        return userRepository.findByUserIdentifier(userIdentifier)
        .map(user -> {
            // UserEntity -> UserResponseDTO 변환
            UserResponseDTO responseDTO = UserResponseDTO.fromEntity(user);
            System.out.println("UserResponseDTO: " + responseDTO);

            return ResponseEntity.ok(responseDTO);
        })
        .orElse(ResponseEntity.notFound().build());
    }


    // function: 회원 가입 시 프로필 업데이트
    @PutMapping("/profile-write/{userIdentifier}")
    public ResponseEntity<String> signInUpdateProfile(@PathVariable("userIdentifier") String userIdentifier, @RequestBody UserUpdateRequestDTO updates) {
        return userRepository.findByUserIdentifier(userIdentifier)
            .map(user -> {
                if (updates.getNickname() != null) {
                    user.setNickname(updates.getNickname());
                }
                if (updates.getBirthDay() != null) {
                    user.setBirthDay(updates.getBirthDay());
                }
                if (updates.getInhabitedPlanet() != null) {
                    user.setInhabitedPlanet(updates.getInhabitedPlanet());
                }
                if (updates.getProfileImage() != null) {
                    user.setProfileImage(updates.getProfileImage());
                }
                userRepository.save(user);
                return ResponseEntity.ok("프로필이 업데이트되었습니다.");
            })
            .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found"));
    }

    // function: 닉네임 중복 체크
    @GetMapping("/check-nickname/{nickname}")
    public ResponseEntity<Boolean> checkNickname(@PathVariable("nickname") String nickname) {
        boolean isUnique = userService.isNicknameUnique(nickname);
        return ResponseEntity.ok(isUnique); // true/false 값 그대로 반환
    }    
    

    // function: 목표행성 업데이트 
    @PutMapping("/update-planet/{userIdentifier}")
    public ResponseEntity<Void> updatePlanet(@PathVariable("userIdentifier") String userIdentifier, @RequestBody DestinationPlanetUpdateRequestDTO requestBody) {
        UserEntity userEntity = userRepository.findByUserIdentifier(userIdentifier)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userIdentifier));
        
        userEntity.setDestinationPlanet(requestBody.getDestinationPlanet());
        userRepository.save(userEntity);
        
        return ResponseEntity.ok().build();
    }


    // function: 프로필 업데이트 
    @PutMapping("/profile-update/{userIdentifier}")
    public ResponseEntity<String> updateProfile(@PathVariable("userIdentifier") String userIdentifier, @RequestBody UserUpdateRequestDTO updates) {
        return userRepository.findByUserIdentifier(userIdentifier)
            .map(user -> {
                if (updates.getNickname() != null) {
                    user.setNickname(updates.getNickname());
                }
                if (updates.getInhabitedPlanet() != null) {
                    user.setInhabitedPlanet(updates.getInhabitedPlanet());
                }
                if (updates.getProfileImage() != null) {
                    user.setProfileImage(updates.getProfileImage());
                }
                userRepository.save(user);
                return ResponseEntity.ok("프로필이 업데이트되었습니다.");
            })
            .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found"));
    }
}
