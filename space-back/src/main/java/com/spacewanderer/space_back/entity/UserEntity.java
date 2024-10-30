package com.spacewanderer.space_back.entity;

import java.util.Random;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "user")
public class UserEntity {
    @Id
    @Column(name = "user_unique_id", nullable = false, unique = true)
    private String userUniqueId;

    @Column(name = "user_identifier", nullable = false, unique = true)
    private String userIdentifier;  // 애플의 userIdentifier로 사용

    @Column(nullable = true)
    private String email;

    @Column(nullable = true)
    private String password;

    @Column(nullable = true)
    private String nickname;

    @Column(nullable = true)
    private String birthDay;

    @Column(nullable = true)
    private String inhabitedPlanet;

    @Column(nullable = true)
    private String profileImage;

    @Column(name = "refresh_token", nullable = false)
    private String refreshToken;  

    @Column(nullable = true)
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