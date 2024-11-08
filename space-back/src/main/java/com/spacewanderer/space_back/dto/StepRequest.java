package com.spacewanderer.space_back.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class StepRequest {

    private String userUniqueId;
    private String walkingDate;
    private int daySteps;
}
