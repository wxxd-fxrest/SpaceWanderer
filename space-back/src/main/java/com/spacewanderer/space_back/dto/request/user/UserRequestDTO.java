package com.spacewanderer.space_back.dto.request.user;

import com.spacewanderer.space_back.entity.UserEntity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UserRequestDTO {
    private String userIdentifier; // 필수 필드
    private String email;
    private String refreshToken;    // 리프레시 토큰
    private String loginType;       // 로그인 타입 (예: kakao, google 등)
    private String nickname; 
    private String birthDay; 
    private String inhabitedPlanet; // 서식지
    private String destinationPlanet; // 목표 행성
    private long dayGoalCount;      // 하루 목표 달성 수

    public UserRequestDTO(String userIdentifier, String email, String refreshToken, String loginType, String nickname, String birthDay, String inhabitedPlanet, String destinationPlanet, long dayGoalCount) {
        this.userIdentifier = userIdentifier;
        this.email = email;
        this.refreshToken = refreshToken; 
        this.loginType = loginType; 
        this.nickname = nickname;
        this.birthDay = birthDay;
        this.inhabitedPlanet = inhabitedPlanet;
        this.destinationPlanet = destinationPlanet;
        this.dayGoalCount = dayGoalCount;
    }

    // DTO -> Entity 변환
    public UserEntity toEntity() {
        return new UserEntity(
                null, // userUniqueId는 자동 생성
                this.userIdentifier,
                this.email,
                null, // refreshToken은 null로 초기화
                null, // loginType은 null로 초기화
                this.destinationPlanet,
                0 // dayGoalCount는 초기값 0으로 설정
        );
    }
}
