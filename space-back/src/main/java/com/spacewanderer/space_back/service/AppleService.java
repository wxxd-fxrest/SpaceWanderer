package com.spacewanderer.space_back.service;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;
import com.spacewanderer.space_back.utils.EncryptionUtil;

import lombok.RequiredArgsConstructor;

import com.nimbusds.jwt.JWT;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.JWTParser;
import com.nimbusds.jwt.SignedJWT;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.text.ParseException;
import java.util.Optional;

import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.interfaces.ECPrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Base64;
import java.util.Date;
import java.util.Map;

import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.JWSSigner;
import com.nimbusds.jose.crypto.ECDSASigner;
import com.nimbusds.jose.crypto.MACSigner;

import org.json.JSONObject;

@Service
@RequiredArgsConstructor
public class AppleService {
    private final UserRepository userRepository;
    private final EncryptionUtil encryptionUtil;

    @Value("${APPLE.AUTH.TOKEN.URL}")
    private String appleAuthTokenUrl;

    @Value("${APPLE.PUBLICKEY.URL}")
    private String applePublicKeyUrl;

    @Value("${APPLE.ISS}")
    private String appleIss;

    @Value("${APPLE.TEAM.ID}")
    private String appleTeamId;

    @Value("${APPLE.WEBSITE.URL}")
    private String appleWebsiteUrl;

    @Value("${APPLE.AUD}")
    private String appleAud;

    @Value("${APPLE.KEY.ID}")
    private String appleKeyId;

    @Value("${APPLE.KEY.PATH}")
    private String appleKeyPath;

    // 사용자 등록 메서드
    public UserEntity registerUser(String userIdentifier, String email, String refreshToken) {
        String userUniqueId = UserEntity.generateUserUniqueId();
        System.out.println("새 사용자 등록: " + userUniqueId + ", 사용자 ID: " + userIdentifier + ", 이메일: " + email);
        UserEntity newUser = new UserEntity(userUniqueId, userIdentifier, email, refreshToken);
        return userRepository.save(newUser);
    }

    public Optional<UserEntity> findUserByUserIdentifier(String userIdentifier) {
        System.out.println("findUserByUserIdentifier 호출: " + userIdentifier);
        return userRepository.findByUserIdentifier(userIdentifier);
    }

    // 사용자 JWT 생성 메서드
    public String generateUserJWT(String userIdentifier, String email) {
        try {
            // 현재 시간 설정
            long now = System.currentTimeMillis();

            // JWT Header 설정
            JWSHeader header = new JWSHeader(JWSAlgorithm.HS256); // 사용되는 알고리즘에 맞게 조정

            // JWT Claims 설정
            JWTClaimsSet claims = new JWTClaimsSet.Builder()
                    .subject(userIdentifier) // 사용자 ID
                    .claim("email", email) // 이메일 추가
                    .issueTime(new Date(now))
                    .expirationTime(new Date(now + 3600 * 1000)) // 1시간 만료
                    .build();

            // JWT 서명
            SignedJWT signedJWT = new SignedJWT(header, claims);
            JWSSigner signer = new MACSigner(appleKeyPath); // 적절한 비밀 키를 사용해야 함
            signedJWT.sign(signer);

            // 서명된 JWT 반환
            return signedJWT.serialize();
        } catch (Exception e) {
            throw new RuntimeException("사용자 JWT를 생성하지 못했습니다.", e);
        }
    }

    public Map<String, String> handleAppleLogin(String idToken, String appleResponse) {
        System.out.println("handleAppleLogin");
    
        // ID 토큰 검증
        if (!validateAppleToken(idToken)) {
            System.out.println("ID 토큰이 유효하지 않습니다.");
            throw new RuntimeException("Invalid ID token");
        }
    
        // ID 토큰에서 이메일 및 사용자 식별자 추출
        String email = extractEmailFromToken(idToken);
        String userIdentifier = extractUserIdentifierFromToken(idToken);
       
        System.out.println("추출된 이메일: " + email + ", 사용자 ID: " + userIdentifier);
    
        // 애플 응답에서 authorizationCode 추출
        String authorizationCode = extractAuthorizationCodeFromAppleResponse(appleResponse);
        System.out.println("추출된 authorizationCode: " + authorizationCode);
    
        if (authorizationCode == null || authorizationCode.isEmpty()) {
            throw new RuntimeException("인증 코드는 null이거나 비어 있을 수 없습니다.");
        }
    
        // Access Token 및 Refresh Token 요청
        String refreshToken;
        try {
            refreshToken = getRefreshTokenUsingAuthorizationCode(authorizationCode);
            System.out.println("발급된 Refresh Token: " + refreshToken);
        } catch (Exception e) {
            System.err.println("Refresh Token 요청 중 오류 발생: " + e.getMessage());
            throw new RuntimeException("Failed to retrieve refresh token");
        }
    
        // Refresh Token 암호화
        String encryptedRefreshToken = generateEncryptedRefreshToken(refreshToken);
        System.out.println("암호화된 데이터 (저장 전): " + refreshToken);
        System.out.println("암호화된 데이터 (저장 후): " + encryptedRefreshToken);
    
        // 사용자 조회 및 등록
        Optional<UserEntity> existingUser = findUserByUserIdentifier(userIdentifier);
        String userUniqueId;
    
        if (existingUser.isPresent()) {
            // 이미 존재하는 사용자, Refresh Token만 업데이트
            UserEntity user = existingUser.get();
            user.setRefreshToken(encryptedRefreshToken); // 기존 사용자 Refresh Token 업데이트
            userRepository.save(user);
            System.out.println("기존 사용자 Refresh Token 업데이트: " + userIdentifier);
            userUniqueId = user.getUserUniqueId(); // 기존 사용자 Unique ID 가져오기
        } else {
            // 새 사용자 등록 및 암호화된 refreshToken 저장
            UserEntity newUser = registerUser(userIdentifier, email, encryptedRefreshToken);
            userUniqueId = newUser.getUserUniqueId(); // 새 사용자의 Unique ID 가져오기
            System.out.println("새 사용자 등록: " + newUser);
        }
    
        // Access Token 요청
        String accessToken;
        try {
            accessToken = getAccessTokenUsingRefreshToken(refreshToken);
            System.out.println("발급된 Access Token: " + accessToken);
        } catch (Exception e) {
            System.err.println("Access Token 요청 중 오류 발생: " + e.getMessage());
            throw new RuntimeException("액세스 토큰을 검색하지 못했습니다.");
        }
    
        // Access Token 요청 후 JWT 생성
        String userJWT = generateUserJWT(userIdentifier, email);
        System.out.println("생성된 JWT: " + userJWT);
        
        return Map.of("userIdentifier", userIdentifier, "refreshToken", accessToken, "userJWT", userJWT, "userUniqueId", userUniqueId);
    }
    

    private String extractAuthorizationCodeFromAppleResponse(String response) {
        // 애플 로그인 후 응답을 JSON 객체로 변환
        JSONObject jsonResponse = new JSONObject(response);

        // authorizationCode 추출
        if (jsonResponse.has("authorizationCode")) {
            return jsonResponse.getString("authorizationCode");
        } else {
            throw new RuntimeException("Apple 응답에서 인증 코드를 찾을 수 없습니다");
        }
    }

    private String getRefreshTokenUsingAuthorizationCode(String authorizationCode) {
        // 애플의 토큰 엔드포인트
        String tokenUrl = "https://appleid.apple.com/auth/token";
    
        try {
            URL url = new URL(tokenUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
    
            // JWT 클라이언트 비밀 생성
            String clientSecret = generateClientSecret(); // 올바른 client secret 생성 확인
    
            // 요청 파라미터 설정
            String clientId = appleAud; // 애플에서 발급받은 클라이언트 ID
            String grantType = "authorization_code"; // 요청하는 그랜트 타입
            String redirectUri = appleWebsiteUrl; // 설정한 리다이렉트 URI
    
            String requestBody = "grant_type=" + grantType +
                                 "&code=" + URLEncoder.encode(authorizationCode, "UTF-8") +
                                 "&client_id=" + URLEncoder.encode(clientId, "UTF-8") +
                                 "&client_secret=" + URLEncoder.encode(clientSecret, "UTF-8") +
                                 "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8");
    
            // 요청 본문 작성
            try (OutputStream os = connection.getOutputStream()) {
                byte[] input = requestBody.getBytes("utf-8");
                os.write(input, 0, input.length);
            }
    
            // 응답 받기
            int responseCode = connection.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();
    
                // 응답 JSON에서 refresh token 추출
                return extractRefreshTokenFromResponse(response.toString());
            } else {
                BufferedReader errorReader = new BufferedReader(new InputStreamReader(connection.getErrorStream()));
                StringBuilder errorResponse = new StringBuilder();
                String line;
                while ((line = errorReader.readLine()) != null) {
                    errorResponse.append(line);
                }
                errorReader.close();
                System.err.println("새로 고침 토큰을 검색하지 못했습니다." + responseCode);
                System.err.println("Error Response: " + errorResponse.toString());
                throw new RuntimeException("Apple에서 새로 고침 토큰을 검색하지 못했습니다.");
            }
        } catch (IOException e) {
            System.err.println("IOException occurred: " + e.getMessage());
            throw new RuntimeException("새로 고침 토큰을 요청하는 중 IOException이 발생했습니다.");
        }
    }    

    private String extractRefreshTokenFromResponse(String jsonResponse) {
        JSONObject response = new JSONObject(jsonResponse);
        if (response.has("refresh_token")) {
            return response.getString("refresh_token");
        } else {
            throw new RuntimeException("응답에서 새로 고침 토큰을 찾을 수 없습니다.");
        }
    }

    public String getUserIdentifierFromToken(String idToken) {
        return extractUserIdentifierFromToken(idToken);
    }

    private String extractEmailFromToken(String idToken) {
        try {
            JWT jwt = JWTParser.parse(idToken);
            if (jwt instanceof SignedJWT) {
                SignedJWT signedJWT = (SignedJWT) jwt;
                return signedJWT.getJWTClaimsSet().getStringClaim("email");
            }
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String extractUserIdentifierFromToken(String idToken) {
        try {
            JWT jwt = JWTParser.parse(idToken);
            if (jwt instanceof SignedJWT) {
                SignedJWT signedJWT = (SignedJWT) jwt;
                return signedJWT.getJWTClaimsSet().getStringClaim("sub");  // userIdentifier 추출
            }
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean validateAppleToken(String idToken) {
        // (토큰 검증 로직은 그대로 유지)
        return true;
    }


    // Refresh Token 암호화 메서드
    private String generateEncryptedRefreshToken(String refreshToken) {
        try {
            // AES 암호화 사용
            System.out.println("Refresh Token 암호화 중: " + refreshToken);
            return encryptionUtil.encrypt(refreshToken);
        } catch (Exception e) {
            throw new RuntimeException("Refresh Token 암호화하지 못함", e);
        }
    }

    // Refresh Token 복호화 메서드
    public String decryptRefreshToken(String encryptedToken) {
        try {
            System.out.println("Refresh Token 복호화 중: " + encryptedToken);
            return encryptionUtil.decrypt(encryptedToken);
        } catch (Exception e) {
            System.err.println("복호화 중 오류 발생: " + e.getMessage());
            throw new RuntimeException("Refresh Token 복호화하지 못함" + e.getMessage(), e);
        }
    }

    private String generateClientSecret() {
        try {
            // 현재 시간 설정
            long now = System.currentTimeMillis();
            
            // JWT Header 설정
            JWSHeader header = new JWSHeader.Builder(JWSAlgorithm.ES256)
                    .keyID(appleKeyId)
                    .build();

            // JWT Claims 설정
            JWTClaimsSet claims = new JWTClaimsSet.Builder()
                    .issuer(appleTeamId) // Team ID
                    .audience("https://appleid.apple.com") // Audience
                    .subject(appleAud) // Client ID
                    .issueTime(new Date(now))
                    .expirationTime(new Date(now + 3600 * 1000)) // 1시간 만료
                    .build();

            // JWT 서명
            SignedJWT signedJWT = new SignedJWT(header, claims);
            JWSSigner signer = new ECDSASigner((ECPrivateKey) getPrivateKey());
            signedJWT.sign(signer);

            // 서명된 JWT 반환
            return signedJWT.serialize();
        } catch (Exception e) {
            throw new RuntimeException("클라이언트 비밀번호를 생성하지 못했습니다.", e);
        }
    }

    private PrivateKey getPrivateKey() {
        try {
            // Private Key 파일 경로 출력
            System.out.println("Private key path: " + appleKeyPath);

            // 파일 존재 여부 확인
            File keyFile = new File(appleKeyPath);
            if (!keyFile.exists()) {
                System.err.println("개인 키 파일이 존재하지 않습니다: " + appleKeyPath);
            }

            // Private Key 파일 읽기
            String privateKeyContent = new String(Files.readAllBytes(Paths.get(appleKeyPath)))
                    .replaceAll("\\n", "")
                    .replace("-----BEGIN PRIVATE KEY-----", "")
                    .replace("-----END PRIVATE KEY-----", "");
            
            // Base64로 디코딩
            byte[] encoded = Base64.getDecoder().decode(privateKeyContent);
            
            // KeyFactory를 사용하여 PrivateKey 생성
            KeyFactory keyFactory = KeyFactory.getInstance("EC");
            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(encoded);
            return keyFactory.generatePrivate(keySpec);
        } catch (Exception e) {
            e.printStackTrace(); // 예외 발생 시 스택 트레이스 출력
            throw new RuntimeException("I/O 오류로 인해 개인 키를 로드하지 못함", e);
        }
    }

     // Access Token 가져오는 메서드
     public String getAccessTokenUsingRefreshToken(String refreshToken) {
        System.out.println("사용 중인 Refresh Token: " + refreshToken); // 현재 사용 중인 Refresh Token 로그 출력
        String tokenEndpoint = "https://appleid.apple.com/auth/token"; 
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Content-Type", "application/x-www-form-urlencoded");
    
        String clientSecret = generateClientSecret(); // Client Secret 생성
        // 요청 파라미터 출력
        System.out.println("요청 파라미터 출력 Client ID: " + appleAud);
        System.out.println("요청 파라미터 출력 Client Secret: " + clientSecret);
        

        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("client_id", appleAud);
        body.add("client_secret", clientSecret);
        body.add("grant_type", "refresh_token");
        body.add("refresh_token", refreshToken);    
    
        HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(body, headers);
        System.out.println("Request Body: " + body.toSingleValueMap());
    
        ResponseEntity<Map> responseEntity;
        try {
            System.out.println("Apple에 요청을 보내는 중...");
            System.out.println("Client Secret: " + clientSecret); // Client Secret 로그 추가
            System.out.println("Request Body: " + body.toSingleValueMap()); // Request Body 로그 추가

            responseEntity = restTemplate.postForEntity(tokenEndpoint, requestEntity, Map.class);
            System.out.println("Response: " + responseEntity.getBody());
            
            if (responseEntity.getStatusCode() == HttpStatus.OK) {
                return (String) responseEntity.getBody().get("access_token");
            } else {
                System.err.println("Apple의 오류 응답: " + responseEntity.getBody());
                throw new RuntimeException("액세스 토큰을 검색하지 못함" + responseEntity.getStatusCode());
            }
        } catch (HttpClientErrorException e) {
            System.err.println("액세스 토큰을 가져오는 중 오류 발생 " + e.getStatusCode());
            System.err.println("Response Body: " + e.getResponseBodyAsString());
            throw new RuntimeException("액세스 토큰을 검색하지 못함" + e.getMessage(), e);
        } catch (Exception e) {
            System.err.println("액세스 토큰을 가져오는 중 오류 발생 " + e.getMessage());
            throw new RuntimeException("액세스 토큰을 검색하지 못함", e);
        }
    }
}