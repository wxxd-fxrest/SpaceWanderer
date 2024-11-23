package com.spacewanderer.space_back.dto.response;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AppleAutoLoginResponseDTO {
    private String accessToken;
    private String userUniqueId;
    private String nickname;

    public AppleAutoLoginResponseDTO(String accessToken, String userUniqueId, String nickname) {
        this.accessToken = accessToken;
        this.userUniqueId = userUniqueId;
        this.nickname = nickname;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getUserUniqueId() {
        return userUniqueId;
    }
    
    public String getNickname() {
        return nickname;
    }
}