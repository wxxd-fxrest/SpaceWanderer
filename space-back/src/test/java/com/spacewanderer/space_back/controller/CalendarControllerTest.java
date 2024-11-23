package com.spacewanderer.space_back.controller;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print; 
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import com.spacewanderer.space_back.entity.StepEntity;
import com.spacewanderer.space_back.repository.StepRepository;

@WebMvcTest(CalendarController.class) // CalendarController만 테스트
@AutoConfigureMockMvc(addFilters = false) // 보안 필터 비활성화
@WithMockUser(username = "testUser", roles = {"USER"}) // 인증된 사용자로 테스트
class CalendarControllerTest {

    @Autowired
    private MockMvc mockMvc;  // MockMvc 인스턴스를 주입받아 테스트 수행

    @MockBean
    private StepRepository stepRepository;  // StepRepository를 모킹하여 의존성 주입

    @Test
    @DisplayName("월별 걸음 수 데이터를 성공적으로 가져오는지 테스트")
    void testGetStepsByMonth() throws Exception {
        // given
        String userUniqueId = "testUserId";
        int year = 2024;
        int month = 11;
        
        // 테스트용 더미 데이터 준비
        StepEntity step1 = new StepEntity(1L, "Destination1", "2024-11-01", 5000, true, userUniqueId);
        StepEntity step2 = new StepEntity(2L, "Destination2", "2024-11-02", 10000, true, userUniqueId);
        List<StepEntity> mockStepData = Arrays.asList(step1, step2);

        // StepRepository가 findAllByUserUniqueIdAndWalkingDateBetween 호출 시 mockStepData를 반환하도록 설정
        when(stepRepository.findAllByUserUniqueIdAndWalkingDateBetween(eq(userUniqueId), anyString(), anyString()))
                .thenReturn(mockStepData);

        // when & then
        mockMvc.perform(get("/api/v1/user/calendar/steps/{userUniqueId}", userUniqueId)  // GET 요청
                        .param("year", String.valueOf(year))  // year 파라미터
                        .param("month", String.valueOf(month)))  // month 파라미터
                        .andDo(print())  // 응답을 콘솔에 출력
                        .andExpect(status().isOk())  // 응답 상태 코드 200 확인
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))  // 응답 타입 JSON 확인
                .andExpect(jsonPath("$", hasSize(2)))  // 반환된 배열의 크기 확인 (2개)
                .andExpect(jsonPath("$[0].dayDestination", is("Destination1")))  // 첫 번째 데이터의 destination 확인
                .andExpect(jsonPath("$[0].walkingDate", is("2024-11-01")))  // 첫 번째 데이터의 walkingDate 확인
                .andExpect(jsonPath("$[0].daySteps", is(5000)))  // 첫 번째 데이터의 daySteps 확인
                .andExpect(jsonPath("$[1].dayDestination", is("Destination2")))  // 두 번째 데이터의 destination 확인
                .andExpect(jsonPath("$[1].walkingDate", is("2024-11-02")))  // 두 번째 데이터의 walkingDate 확인
                .andExpect(jsonPath("$[1].daySteps", is(10000)));  // 두 번째 데이터의 daySteps 확인

        // verify: stepRepository의 findAllByUserUniqueIdAndWalkingDateBetween가 한 번 호출되었는지 확인
        Mockito.verify(stepRepository).findAllByUserUniqueIdAndWalkingDateBetween(
            eq(userUniqueId), 
            anyString(), 
            anyString());
    }
}
