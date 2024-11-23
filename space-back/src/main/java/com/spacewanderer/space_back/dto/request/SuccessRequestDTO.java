package com.spacewanderer.space_back.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class SuccessRequestDTO {

    private Long dayId;         // StepEntity의 dayId
    private String userUniqueId; // 사용자 고유 ID

    public SuccessRequestDTO(Long dayId, String userUniqueId) {
        this.dayId = dayId;
        this.userUniqueId = userUniqueId;
    }
}
