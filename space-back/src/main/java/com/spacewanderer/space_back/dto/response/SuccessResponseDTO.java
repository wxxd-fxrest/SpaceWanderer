package com.spacewanderer.space_back.dto.response;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class SuccessResponseDTO {

    private Long countId;       // SuccessEntity의 countId
    private Long dayId;         // StepEntity의 dayId
    private String userUniqueId; // 사용자 고유 ID

    public SuccessResponseDTO(Long countId, Long dayId, String userUniqueId) {
        this.countId = countId;
        this.dayId = dayId;
        this.userUniqueId = userUniqueId;
    }
}
