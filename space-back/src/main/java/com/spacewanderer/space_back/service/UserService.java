package com.spacewanderer.space_back.service;

import java.util.Optional;

import org.springframework.stereotype.Service;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;

    // 닉네임 중복 체크
    public boolean isNicknameUnique(String nickname) {
        // 사용자 정보를 데이터베이스에서 찾기 (닉네임을 기준으로)
        Optional<UserEntity> user = userRepository.findByNickname(nickname);
        
        // 이미 존재하는 닉네임이 있으면 false 반환, 없으면 true 반환
        return !user.isPresent();
    }

    public void updatePlanet(String userIdentifier, String destinationPlanet) {
        // userId를 통해 사용자를 검색
        UserEntity userEntity = userRepository.findByUserIdentifier(userIdentifier)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userIdentifier));
        
        // 행성 이름 업데이트
        userEntity.setDestinationPlanet(destinationPlanet);
        
        // 변경 사항 저장
        userRepository.save(userEntity);
    }
}
