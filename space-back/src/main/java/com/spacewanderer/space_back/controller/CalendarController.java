package com.spacewanderer.space_back.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.entity.StepEntity;
import com.spacewanderer.space_back.repository.StepRepository;
import com.spacewanderer.space_back.service.CalendarService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/user/calendar")
@RequiredArgsConstructor
public class CalendarController {
    
    private final CalendarService calendarService; 
    private final StepRepository stepRepository;

    // function: 년/월에 해당하는 걸음 수 데이터 요청
    @GetMapping("/steps/{userUniqueId}")
    public List<StepEntity> getStepsByMonth(
            @PathVariable("userUniqueId") String userUniqueId,
            @RequestParam("year") int year,
            @RequestParam("month") int month) {
        System.out.println(" List<StepEntity> getStepsByMonth(");
        // "yyyy-MM" 형식으로 변환
        String startOfMonth = String.format("%04d-%02d-01", year, month);
        String endOfMonth = String.format("%04d-%02d-%02d", year, month, calendarService.getLastDayOfMonth(year, month)); // 마지막 날짜 계산
        
        // 출력
        System.out.println("Request received for user: " + userUniqueId + ", Year: " + year + ", Month: " + month);
        System.out.println("startOfMonth: " + startOfMonth + " endOfMonth" + endOfMonth);
        
        // 월의 시작과 끝 날짜를 기준으로 데이터 조회
        List<StepEntity> stepData = stepRepository.findAllByUserUniqueIdAndWalkingDateBetween(userUniqueId, startOfMonth, endOfMonth);
        
        // 조회된 데이터 출력
        System.out.println("Retrieved Step Data: " + stepData);
        
        return stepData;
    }     
}