package com.spacewanderer.space_back.service;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KakaoService {
    private final UserRepository userRepository;

    @Value("${KAKAO.TOKEN.URL}")
    private String kakaoTokenUrl;

    @Value("${KAKAO.REDIRECT.URL}")
    private String kakaoRedirectUrl;

    @Value("${KAKAO.REST.API.KEY}")
    private String kakaoAppKey;

    // function: 사용자 정보 DB 저장 
    public UserEntity registerUser(String userIdentifier, String email, String refreshToken, String loginType) {
        String userUniqueId = UserEntity.generateUserUniqueId();
        UserEntity newUser = new UserEntity(userUniqueId, userIdentifier, email, refreshToken, loginType);
        System.out.println("registerUser | " + newUser);
        return userRepository.save(newUser);
    }

    // function: 리프레시 토큰만 업데이트 
    public UserEntity updateRefreshToken(String userIdentifier, String newRefreshToken) {
        UserEntity user = userRepository.findByUserIdentifier(userIdentifier)
                .orElseThrow(() -> new RuntimeException("User not found"));
        System.out.println("updateRefreshToken | " + newRefreshToken);
        user.setRefreshToken(newRefreshToken); // 리프레시 토큰 업데이트
        return userRepository.save(user); // 변경된 사용자 정보 저장
    }
    
    // function: Access Token 가져오기 (리프레시 토큰 만료 시 예외 처리 추가) 
    public String getAccessToken(String refreshToken) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "refresh_token");
        params.add("client_id", kakaoAppKey);
        params.add("refresh_token", refreshToken);
        params.add("redirect_uri", kakaoRedirectUrl);

        RestTemplate restTemplate = new RestTemplate();
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(org.springframework.http.MediaType.APPLICATION_FORM_URLENCODED);
        
        HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(params, headers);
        
        try {
            ResponseEntity<Map> response = restTemplate.exchange(kakaoTokenUrl, HttpMethod.POST, requestEntity, Map.class);
            System.out.println("Response String | " + response);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                return (String) response.getBody().get("access_token");
            } else {
                throw new RuntimeException("액세스 토큰을 검색하지 못했습니다. " + response.getStatusCode());
            }
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.UNAUTHORIZED) {
                throw new RuntimeException("Refresh Token이 만료되었습니다.");
            } else {
                throw new RuntimeException("액세스 토큰을 검색하지 못했습니다. " + e.getStatusCode());
            }
        } catch (Exception e) {
            throw new RuntimeException("액세스 토큰을 검색하지 못했습니다: " + e.getMessage());
        }
    }
}
