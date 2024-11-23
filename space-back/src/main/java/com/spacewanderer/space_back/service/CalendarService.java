package com.spacewanderer.space_back.service;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CalendarService {
    
    // 월의 마지막 날짜를 계산하는 메서드
    public int getLastDayOfMonth(int year, int month) {
        // 2월의 마지막 날짜 계산
        if (month == 2) {
            return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
        }
        // 4, 6, 9, 11월은 30일, 나머지 월은 31일
        return (month == 4 || month == 6 || month == 9 || month == 11) ? 30 : 31;
    }
}
