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
}
