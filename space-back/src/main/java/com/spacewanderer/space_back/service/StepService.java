package com.spacewanderer.space_back.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.spacewanderer.space_back.dto.response.StepResponseDTO;
import com.spacewanderer.space_back.entity.StepEntity;
import com.spacewanderer.space_back.entity.SuccessEntity;
import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.StepRepository;
import com.spacewanderer.space_back.repository.SuccessRepository;
import com.spacewanderer.space_back.repository.UserRepository;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Service
@RequiredArgsConstructor
public class StepService {

    private final StepRepository stepRepository;
    private final SuccessRepository successRepository;
    private final UserRepository userRepository;

    // function: 마지막 기록된 날짜 가져오기
    public StepResponseDTO getLastStepDay(String userUniqueId) {
        // 사용자의 마지막 기록된 날짜 조회
        StepEntity lastStep = stepRepository.findTopByUserUniqueIdOrderByWalkingDateDesc(userUniqueId);
        
        StepResponseDTO response = new StepResponseDTO();
        if (lastStep != null) {
            response.setWalkingDate(lastStep.getWalkingDate());
        } 
        System.out.println("StepService: " + response);
        System.out.println("StepService lastStep: " + lastStep);
        return response;
    }
    

    private List<PlanetVisitUpdateRequest> planetVisitRequests = new ArrayList<>();

    // PlanetVisitUpdateRequest 클래스 정의
    @Getter
    @Setter
    public static class PlanetVisitUpdateRequest {
        private String userUniqueId;
        private String planetName;
        private String visitDate;

        public PlanetVisitUpdateRequest(String userUniqueId, String planetName, String visitDate) {
            this.userUniqueId = userUniqueId;
            this.planetName = planetName;
            this.visitDate = visitDate;
        }
    }

    // function: 하루 걸음 수 저장
    public void saveDaySteps(String userUniqueId, String walkingDate, int daySteps, String dayDestination) {
        // 날짜와 사용자 고유 ID로 이미 기록된 데이터가 있는지 확인
        StepEntity existingStep = stepRepository.findByUserUniqueIdAndWalkingDate(userUniqueId, walkingDate);
        
        if (existingStep != null) {
            // 기존에 기록된 데이터가 있다면 업데이트
            existingStep.setDaySteps(daySteps);
            existingStep.setDayDestination(dayDestination);
            // existingStep.setDayDestination(dayDestination);
            stepRepository.save(existingStep);
    
            // 10,000보 이상인 경우 성공 기록 추가
            checkAndSaveSuccess(existingStep, walkingDate);
        } else {
            // 기록된 데이터가 없다면 새로운 데이터로 저장
            StepEntity newStep = new StepEntity();
            newStep.setUserUniqueId(userUniqueId);
            newStep.setWalkingDate(walkingDate);
            newStep.setDaySteps(daySteps);
            newStep.setDayDestination(dayDestination);
            stepRepository.save(newStep);
    
            // 10,000보 이상인 경우 성공 기록 추가
            checkAndSaveSuccess(newStep, walkingDate);
        }
    }
    
    // function: 10,000보 이상인 경우 success_count 테이블에 기록 추가
    private void checkAndSaveSuccess(StepEntity step, String walkingDate) {
        // 성공 조건 확인 (예: 10,000보 이상)
        if (step.getDaySteps() >= 1000) {
            System.out.println("현재 걸음 수: " + step.getDaySteps());

            // 중복 방지를 위해 이미 성공 기록이 있는지 확인
            boolean exists = successRepository.existsByUserUniqueIdAndDayId(step.getUserUniqueId(), step.getDayId());

            if (!exists) {
                // 새로운 성공 기록 추가
                SuccessEntity successEntity = new SuccessEntity();
                successEntity.setUserUniqueId(step.getUserUniqueId());
                successEntity.setDayId(step.getDayId());
                successRepository.save(successEntity);
                System.out.println("성공 기록 추가 완료: " + successEntity);

                // Planet 방문 요청 정보를 리스트에 저장
                planetVisitRequests.add(new PlanetVisitUpdateRequest(step.getUserUniqueId(), step.getDayDestination(), walkingDate)); // 방문 요청 추가
            } else { 
                System.out.println("중복: 이미 성공 기록이 존재합니다.");
            }
        } else {
            System.out.println("성공 조건 미충족: " + step.getDaySteps() + "보");
        }

        // 성공 기록의 총 개수를 구하고 dayGoalCount 업데이트
        updateUserDayGoalCount(step.getUserUniqueId());
    }

    // function: 사용자 dayGoalCount 값 업데이트
    private void updateUserDayGoalCount(String userUniqueId) {
        // success_count 테이블에서 해당 사용자의 성공 기록 수를 조회
        long successCount = successRepository.countByUserUniqueId(userUniqueId);

        // user 테이블에서 사용자 조회
        Optional<UserEntity> userOptional = userRepository.findByUserUniqueId(userUniqueId);

        if (userOptional.isPresent()) {
            UserEntity userEntity = userOptional.get();
            // dayGoalCount를 successCount로 설정
            userEntity.setDayGoalCount(successCount);
            userRepository.save(userEntity);
            System.out.println("dayGoalCount 업데이트 완료: " + userEntity.getDayGoalCount());
        } else {
            System.out.println("사용자를 찾을 수 없습니다: " + userUniqueId);
        }
    }
}