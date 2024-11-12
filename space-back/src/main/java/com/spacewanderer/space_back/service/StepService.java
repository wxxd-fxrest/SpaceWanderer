package com.spacewanderer.space_back.service;

import org.springframework.stereotype.Service;

import com.spacewanderer.space_back.dto.StepResponse;
import com.spacewanderer.space_back.entity.StepEntity;
import com.spacewanderer.space_back.repository.StepRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class StepService {

    private final StepRepository stepRepository;

    // 마지막 기록된 날짜 가져오기
    public StepResponse getLastStepDay(String userUniqueId) {
        // 사용자의 마지막 기록된 날짜 조회
        StepEntity lastStep = stepRepository.findTopByUserUniqueIdOrderByWalkingDateDesc(userUniqueId);
        
        StepResponse response = new StepResponse();
        if (lastStep != null) {
            response.setWalkingDate(lastStep.getWalkingDate());
        } 
        
        return response;
    }
    // 하루 걸음 수 저장
    public void saveDaySteps(String userUniqueId, String walkingDate, int daySteps, String dayDestination) {
        // 날짜와 사용자 고유 ID로 이미 기록된 데이터가 있는지 확인
        StepEntity existingStep = stepRepository.findByUserUniqueIdAndWalkingDate(userUniqueId, walkingDate);
        
        if (existingStep != null) {
            // 기존에 기록된 데이터가 있다면 업데이트
            existingStep.setDaySteps(daySteps);
            // existingStep.setDayDestination(dayDestination);
            stepRepository.save(existingStep);
        } else {
            // 기록된 데이터가 없다면 새로운 데이터로 저장
            StepEntity newStep = new StepEntity();
            newStep.setUserUniqueId(userUniqueId);
            newStep.setWalkingDate(walkingDate);
            newStep.setDaySteps(daySteps);
            newStep.setDayDestination(dayDestination);
            stepRepository.save(newStep);
        }
    }
}
