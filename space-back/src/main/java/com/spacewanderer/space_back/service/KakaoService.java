package com.spacewanderer.space_back.service;

import java.util.Map;

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
import com.spacewanderer.space_back.utils.EncryptionUtil;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KakaoService {
    private final UserRepository userRepository;
    private final EncryptionUtil encryptionUtil;

    @Value("${KAKAO.TOKEN.URL}")
    private String kakaoTokenUrl;

    @Value("${KAKAO.REDIRECT.URL}")
    private String kakaoRedirectUrl;

    @Value("${KAKAO.REST.API.KEY}")
    private String kakaoAppKey;

    // function: 사용자 정보 DB 저장
    public UserEntity registerUser(String userIdentifier, String email, String refreshToken, String loginType, String destinationPlanet, long dayGoalCount) {
        // 기존 사용자 조회
        UserEntity existingUser = userRepository.findByUserIdentifier(userIdentifier).orElse(null);

        // 이미 회원 정보가 있는 경우 리프레시 토큰만 업데이트
        if (existingUser != null) {
            System.out.println("기존 회원 정보가 있어 리프레시 토큰만 업데이트합니다.");
            return updateRefreshToken(userIdentifier, refreshToken);
        }

        // 새 사용자 등록
        String userUniqueId = UserEntity.generateUserUniqueId();
        System.out.println("암호화 전 refreshToken | " + refreshToken);

        // 리프레시 토큰 암호화
        String encryptedRefreshToken;
        try {
            encryptedRefreshToken = encryptionUtil.encrypt(refreshToken);
        } catch (Exception e) {
            throw new RuntimeException("리프레시 토큰 암호화에 실패했습니다.", e);
        }

        System.out.println("암호화 후 refreshToken | " + encryptedRefreshToken);

        UserEntity newUser = new UserEntity(userUniqueId, userIdentifier, email, encryptedRefreshToken, loginType, "지구", 0);
        System.out.println("registerUser | " + newUser);
        return userRepository.save(newUser);
    }

    // function: 리프레시 토큰만 업데이트
    public UserEntity updateRefreshToken(String userIdentifier, String newRefreshToken) {
        System.out.println("newRefreshToken: " + newRefreshToken);
        UserEntity user = userRepository.findByUserIdentifier(userIdentifier)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // 리프레시 토큰 암호화
        String encryptedRefreshToken;
        try {
            encryptedRefreshToken = encryptionUtil.encrypt(newRefreshToken);
        } catch (Exception e) {
            throw new RuntimeException("리프레시 토큰 암호화에 실패했습니다.", e);
        }

        System.out.println("updateRefreshToken | " + encryptedRefreshToken);
        user.setRefreshToken(encryptedRefreshToken); // 리프레시 토큰 업데이트
        return userRepository.save(user); // 변경된 사용자 정보 저장
    }

    // function: Access Token 가져오기 (리프레시 토큰 만료 시 예외 처리 추가)
    public String getAccessToken(String refreshToken, String userIdentifier) {
        System.out.println("복호화 전 refreshToken | " + refreshToken);
        // 리프레시 토큰 복호화
        String decryptedRefreshToken;
        try {
            decryptedRefreshToken = encryptionUtil.decrypt(refreshToken);
        } catch (Exception e) {
            throw new RuntimeException("리프레시 토큰 복호화에 실패했습니다.", e);
        }
        System.out.println("복호화 후 refreshToken | " + decryptedRefreshToken);

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "refresh_token");
        params.add("client_id", kakaoAppKey);
        params.add("refresh_token", decryptedRefreshToken);
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
                // 리프레시 토큰이 만료된 경우, 새 리프레시 토큰을 받아와 갱신
                String newRefreshToken = refreshAndSaveNewRefreshToken(userIdentifier, refreshToken);
                return getAccessToken(newRefreshToken, userIdentifier);
            } else {
                throw new RuntimeException("액세스 토큰을 검색하지 못했습니다. " + e.getStatusCode());
            }
        } catch (Exception e) {
            throw new RuntimeException("액세스 토큰을 검색하지 못했습니다: " + e.getMessage());
        }
    }

    // function: 새 리프레시 토큰 갱신
    public String refreshAndSaveNewRefreshToken(String userIdentifier, String currentRefreshToken) {
        // 현재 리프레시 토큰을 복호화
        String decryptedRefreshToken;
        try {
            decryptedRefreshToken = encryptionUtil.decrypt(currentRefreshToken);
        } catch (Exception e) {
            throw new RuntimeException("리프레시 토큰 복호화에 실패했습니다.", e);
        }

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "refresh_token");
        params.add("client_id", kakaoAppKey);
        params.add("refresh_token", decryptedRefreshToken);

        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(org.springframework.http.MediaType.APPLICATION_FORM_URLENCODED);
        HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(params, headers);

        try {
            ResponseEntity<Map> response = restTemplate.exchange(kakaoTokenUrl, HttpMethod.POST, requestEntity, Map.class);
            if (response.getStatusCode().is2xxSuccessful()) {
                String newRefreshToken = (String) response.getBody().get("refresh_token");
                
                // 새로운 리프레시 토큰이 있다면 암호화하고 DB에 업데이트
                if (newRefreshToken != null) {
                    return updateRefreshToken(userIdentifier, newRefreshToken).getRefreshToken();
                } else {
                    throw new RuntimeException("새로운 리프레시 토큰을 받지 못했습니다.");
                }
            } else {
                throw new RuntimeException("리프레시 토큰 갱신 요청 실패: " + response.getStatusCode());
            }
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.UNAUTHORIZED) {
                throw new RuntimeException("리프레시 토큰이 만료되었습니다.");
            } else {
                throw new RuntimeException("리프레시 토큰 갱신 중 오류 발생: " + e.getStatusCode());
            }
        } catch (Exception e) {
            throw new RuntimeException("리프레시 토큰 갱신 중 예기치 않은 오류 발생: " + e.getMessage());
        }
    }
}
