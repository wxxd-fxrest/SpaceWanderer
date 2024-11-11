package com.spacewanderer.space_back.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class StepResponse {

    private String dayDestination; // 예시로 명왕성
    private String walkingDate;
    private int daySteps;
    private boolean dayGoal;  // 목표 달성 여부

    public StepResponse(String dayDestination, String walkingDate, int daySteps, boolean dayGoal) {
        this.dayDestination = dayDestination;
        this.walkingDate = walkingDate;
        this.daySteps = daySteps;
        this.dayGoal = dayGoal;
    }

    public String getWalkingDate() {
        return walkingDate;
    }
}
