package com.spacewanderer.space_back.entity;

import java.util.Random;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Table(name = "user")
@Entity(name = "user")
public class UserEntity {
    @Id
    @Column(name = "user_unique_id", nullable = false, unique = true)
    private String userUniqueId;

    @Column(name = "user_identifier", nullable = false, unique = true)
    private String userIdentifier; 

    private String email;

    private String password;

    private String nickname;

    private String birthDay;

    private String inhabitedPlanet;

    private String profileImage;

    private String refreshToken;  

    private String loginType;

    public UserEntity(String userUniqueId, String userIdentifier, String email, String refreshToken, String loginType) {
        this.userUniqueId = userUniqueId;
        this.userIdentifier = userIdentifier;
        this.email = email;
        this.refreshToken = refreshToken;
        this.loginType = loginType;
    }

    // 고유 ID 생성 메서드
    public static String generateUserUniqueId() {
        Random random = new Random();
        return String.valueOf(100 + random.nextInt(900));
    }
}