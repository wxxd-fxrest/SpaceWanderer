package com.spacewanderer.space_back.dto.request.apple;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AppleLoginRequestDTO {
    private String idToken;
    private String appleResponse;
    private String deviceToken;

    // Getter, Setter, Constructor 등 추가
}