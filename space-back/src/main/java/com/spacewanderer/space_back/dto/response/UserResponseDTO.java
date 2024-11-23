package com.spacewanderer.space_back.dto.response;

import com.spacewanderer.space_back.entity.UserEntity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UserResponseDTO {
    private String userUniqueId;
    private String userIdentifier;
    private String nickname;
    private String refreshToken; 
    private String birthDay;
    private String inhabitedPlanet;
    private String profileImage;
    private long dayGoalCount;
    private String destinationPlanet;

    public UserResponseDTO(String userUniqueId, String userIdentifier, String nickname, String refreshToken, String birthDay, String inhabitedPlanet, String destinationPlanet, long dayGoalCount, String profileImage) {
        this.userUniqueId = userUniqueId;
        this.userIdentifier = userIdentifier;
        this.nickname = nickname;
        this.refreshToken = refreshToken; 
        this.birthDay = birthDay;
        this.inhabitedPlanet = inhabitedPlanet;
        this.profileImage = profileImage;
        this.dayGoalCount = dayGoalCount;
        this.destinationPlanet = destinationPlanet;
    }

    // Entity -> DTO 변환
    public static UserResponseDTO fromEntity(UserEntity userEntity) {
        System.out.println("UserEntity: " + userEntity);
        return new UserResponseDTO(
                userEntity.getUserUniqueId(),
                userEntity.getUserIdentifier(),
                userEntity.getNickname(),
                userEntity.getRefreshToken(),
                userEntity.getBirthDay(),
                userEntity.getInhabitedPlanet(),
                userEntity.getDestinationPlanet(),
                userEntity.getDayGoalCount(),
                userEntity.getProfileImage()
        );
    }
}
