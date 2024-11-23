package com.spacewanderer.space_back.dto.response;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class StepResponseDTO {

    private String dayDestination; // 예시로 명왕성
    private String walkingDate;
    private int daySteps;
    private boolean dayGoal;  // 목표 달성 여부

    public StepResponseDTO(String dayDestination, String walkingDate, int daySteps, boolean dayGoal) {
        this.dayDestination = dayDestination;
        this.walkingDate = walkingDate;
        this.daySteps = daySteps;
        this.dayGoal = dayGoal;
    }

    public String getWalkingDate() {
        return walkingDate;
    }
}
