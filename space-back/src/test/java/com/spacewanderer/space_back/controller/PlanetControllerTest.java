package com.spacewanderer.space_back.controller;

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

import com.spacewanderer.space_back.entity.PlanetEntity;
import com.spacewanderer.space_back.service.PlanetService;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print; // 올바른 import 구문
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PlanetController.class) // PlanetController만 테스트
@AutoConfigureMockMvc(addFilters = false) // 보안 필터 비활성화
@WithMockUser(username = "testUser", roles = {"USER"}) // 인증된 사용자로 테스트
class PlanetControllerTest {

    @Autowired
    private MockMvc mockMvc;  // MockMvc 인스턴스를 주입받아 테스트 수행

    @MockBean
    private PlanetService planetService;  // PlanetService를 모킹하여 의존성 주입

    @Test
    @DisplayName("모든 행성 데이터를 성공적으로 가져오는지 테스트")
    void testGetAllPlanets() throws Exception {
        // given
        PlanetEntity earth = new PlanetEntity("Earth", "3rd planet from the Sun", "image", 0);
        PlanetEntity mars = new PlanetEntity("Mars", "4th planet from the Sun", "image2", 10);
        List<PlanetEntity> mockPlanets = Arrays.asList(earth, mars);  // 테스트용 더미 데이터 준비

        // PlanetService가 getAllPlanets 호출 시 mockPlanets를 반환하도록 설정
        when(planetService.getAllPlanets()).thenReturn(mockPlanets);

        // when & then
        mockMvc.perform(get("/api/v1/planet/get-all-planet")  // get 요청
                        .contentType(MediaType.APPLICATION_JSON))  // 응답 타입 JSON 설정
                .andDo(print())  // 응답을 콘솔에 출력
                .andExpect(status().isOk())  // 응답 상태 코드 200 확인
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))  // 응답 타입 확인
                .andExpect(jsonPath("$", hasSize(2)))  // 반환된 배열의 크기 확인 (2개)
                .andExpect(jsonPath("$[0].name", is("Earth")))  // 첫 번째 행성의 이름 확인
                .andExpect(jsonPath("$[0].description", is("3rd planet from the Sun")))  // 첫 번째 행성의 설명 확인
                .andExpect(jsonPath("$[1].name", is("Mars")))  // 두 번째 행성의 이름 확인
                .andExpect(jsonPath("$[1].description", is("4th planet from the Sun")));  // 두 번째 행성의 설명 확인

        // verify: planetService의 getAllPlanets가 한 번 호출되었는지 확인
        Mockito.verify(planetService).getAllPlanets();
    }
}
