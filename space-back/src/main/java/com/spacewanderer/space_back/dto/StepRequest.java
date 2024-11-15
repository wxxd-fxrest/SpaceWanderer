package com.spacewanderer.space_back.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class StepRequest {
    private String userUniqueId;
    private String walkingDate;
    private int daySteps;
    private String dayDestination; // 예시로 명왕성

    public void setStepRequest(String userUniqueId, String walkingDate, int daySteps, String dayDestination) {
        this.userUniqueId = userUniqueId;
        this.walkingDate = walkingDate;
        this.daySteps = daySteps;
        this.dayDestination = dayDestination; 
    }
}
