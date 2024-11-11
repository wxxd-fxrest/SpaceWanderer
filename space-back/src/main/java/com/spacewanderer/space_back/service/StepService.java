package com.spacewanderer.space_back.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.spacewanderer.space_back.dto.StepResponse;
import com.spacewanderer.space_back.entity.StepEntity;
import com.spacewanderer.space_back.repository.StepRepository;

import lombok.RequiredArgsConstructor;
import net.bytebuddy.asm.MemberSubstitution.Substitution.Chain.Step;

@Service
@RequiredArgsConstructor
public class StepService {

    private final StepRepository stepRepository;

    // public StepResponse getDaySteps(String userUniqueId, String walkingDate) {
    //     // 1. 날짜 포맷에 맞게 파싱
    //     LocalDate date = LocalDate.parse(walkingDate, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        
    //     // 2. 하루 걸음 수 조회
    //     Optional<StepEntity> stepData = stepRepository.findByUserUniqueIdAndWalkingDate(userUniqueId, date);
        
    //     // 3. 결과 처리
    //     StepEntity stepEntity = stepData.orElseGet(() -> {
    //         // 만약 데이터가 없다면, 새로운 데이터 생성
    //         StepEntity newStep = new StepEntity();
    //         newStep.setDayDestination("명왕성");
    //         newStep.setWalkingDate(date);
    //         newStep.setDaySteps(0);  // 기본값 0
    //         newStep.setDayGoal(false);  // 기본값 false
    //         newStep.setUserUniqueId(userUniqueId);
    //         stepRepository.save(newStep); // 데이터 삽입
    //         return newStep;
    //     });

    //     // 목표 달성 여부 계산
    //     boolean dayGoalAchieved = stepEntity.getDaySteps() >= 10000; // 예시로 목표 10000걸음

    //     return new StepResponse(
    //         stepEntity.getDayDestination(),
    //         stepEntity.getWalkingDate().toString(),
    //         stepEntity.getDaySteps(),
    //         dayGoalAchieved
    //     );
    // }

    // 마지막 기록된 날짜 조회
    // public StepResponse getLastStepDay(String userUniqueId) {
    //     // 가장 최근의 데이터 가져오기
    //     Optional<StepEntity> lastStepData = stepRepository.findTopByUserUniqueIdOrderByWalkingDateDesc(userUniqueId);

    //     if (lastStepData.isPresent()) {
    //         StepEntity stepEntity = lastStepData.get();
    //         boolean dayGoalAchieved = stepEntity.getDaySteps() >= 10000;  // 예시 목표: 10000걸음

    //         return new StepResponse(
    //             stepEntity.getDayDestination(),
    //             stepEntity.getWalkingDate().toString(),
    //             stepEntity.getDaySteps(),
    //             dayGoalAchieved
    //         );
    //     } else {
    //         // 데이터가 없으면 기본값으로 응답
    //         return new StepResponse("명왕성", LocalDate.now().toString(), 0, false);
    //     }
    // }

    // 데이터를 삽입하는 메소드 추가 (예시)
    // public void saveDaySteps(String userUniqueId, String walkingDate, int steps) {
    //     System.out.println("saveDaySteps");
    //     LocalDate date = LocalDate.parse(walkingDate, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    //     StepEntity newStep = new StepEntity();
    //     newStep.setDayDestination("명왕성");  // 예시로 "명왕성"
    //     newStep.setWalkingDate(date);
    //     newStep.setDaySteps(steps);
    //     newStep.setDayGoal(steps >= 10000);  // 예시로 목표 10000걸음
    //     newStep.setUserUniqueId(userUniqueId);

    //     stepRepository.save(newStep); // 데이터 저장
    // }


    // 마지막 기록된 날짜 가져오기
    public StepResponse getLastStepDay(String userUniqueId) {
        // 사용자의 마지막 기록된 날짜 조회
        StepEntity lastStep = stepRepository.findTopByUserUniqueIdOrderByWalkingDateDesc(userUniqueId);
        
        StepResponse response = new StepResponse();
        if (lastStep != null) {
            response.setWalkingDate(lastStep.getWalkingDate());
        } 
        // else {
        //     response.setWalkingDate(LocalDate.now().minusDays(1).toString()); // 첫 기록이 없다면 어제 날짜를 반환
        // }
        
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
