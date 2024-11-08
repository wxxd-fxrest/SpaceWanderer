package com.spacewanderer.space_back.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.dto.StepRequest;
import com.spacewanderer.space_back.dto.StepResponse;
import com.spacewanderer.space_back.service.StepService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/walk")
@RequiredArgsConstructor
public class StepController {

    private final StepService stepService;

    // 하루 걸음 수 조회
    @GetMapping("/day-walking/{userUniqueId}")
    public ResponseEntity<StepResponse> getDaySteps(@PathVariable String userUniqueId, @RequestParam String walkingDate) {
        StepResponse stepResponse = stepService.getDaySteps(userUniqueId, walkingDate);
        return ResponseEntity.ok(stepResponse);
    }

    // 하루 걸음 수 저장
    @PostMapping("/day-walking")
    public ResponseEntity<Void> saveDaySteps(@RequestBody StepRequest stepRequest) {
        stepService.saveDaySteps(stepRequest.getUserUniqueId(), stepRequest.getWalkingDate(), stepRequest.getDaySteps());
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
}

