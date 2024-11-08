package com.spacewanderer.space_back.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StepResponse {

    private String dayDestination; // 예시로 명왕성
    private String walkingDate;
    private int daySteps;
    private boolean dayGoal;  // 목표 달성 여부
}
