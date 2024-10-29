package com.spacewanderer.space_back.service;

import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.spacewanderer.space_back.dto.KakaoUserDTO;
import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KakaoService {
    @Value("${KAKAO.REDIRECT.URL}")
    private String kakaoRedirectUrl;
    // REST API Key 주입
    @Value("${KAKAO.REST.API.KEY}")
    private String kakaoApiKey;

}
