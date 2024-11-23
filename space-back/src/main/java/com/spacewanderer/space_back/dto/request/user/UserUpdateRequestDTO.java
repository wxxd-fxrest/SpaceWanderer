package com.spacewanderer.space_back.dto.request.user;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UserUpdateRequestDTO {
    private String nickname;
    private String birthDay;
    private String inhabitedPlanet;
    private String profileImage;
    
    // Getter, Setter, Constructor
}

