package com.spacewanderer.space_back.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class KakaoUserDTO {
    private String id;
    private String email;
    private String refreshToken;

    public String getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getRefreshToken() {
        return refreshToken;
    }


    public KakaoUserDTO(String id, String email, String refreshToken) {
        this.id = id;
        this.email = email;
        this.refreshToken = refreshToken;
    }
}