package com.spacewanderer.space_back.service;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.GuestBookFavoriteRepository;
import com.spacewanderer.space_back.repository.GuestBookRepository;
import com.spacewanderer.space_back.repository.StepRepository;
import com.spacewanderer.space_back.repository.SuccessRepository;
import com.spacewanderer.space_back.repository.UserRepository;
import com.spacewanderer.space_back.utils.EncryptionUtil;

import jakarta.transaction.Transactional;
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

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.JWSObject;
import com.nimbusds.jose.JWSSigner;
import com.nimbusds.jose.crypto.ECDSASigner;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.jwk.JWK;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.RSAKey;

import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
@RequiredArgsConstructor
public class AppleService {    
    private final UserRepository userRepository; 
    private final GuestBookFavoriteRepository guestBookFavoriteRepository;
    private final GuestBookRepository guestBookRepository;
    private final SuccessRepository successRepository;
    private final StepRepository stepRepository;
    private final EncryptionUtil encryptionUtil;

    @Value("${apple.auth-token-url}")
    private String appleAuthTokenUrl;

    @Value("${apple.publickey-url}")
    private String applePublicKeyUrl;

    @Value("${apple.iss}")
    private String appleIss;

    @Value("${apple.team-id}")
    private String appleTeamId;

    @Value("${apple.website-url}")
    private String appleWebsiteUrl;

    @Value("${apple.aud}")
    private String appleAud;

    @Value("${apple.key-id}")
    private String appleKeyId;

    @Value("${apple.key-path}")
    private String appleKeyPath;
    
    private static final Logger logger = LoggerFactory.getLogger(AppleService.class);

    // function: 사용자 정보 DB 저장 
    public UserEntity registerUser(String userIdentifier, String email, String refreshToken, String lginType, String destinationPlanet, long dayGoalCount) {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("유효하지 않은 이메일 주소입니다.");
        }

        String userUniqueId = UserEntity.generateUserUniqueId();
        UserEntity newUser = new UserEntity(userUniqueId, userIdentifier, email, refreshToken, "apple", "수성", 0); 
            
        return userRepository.save(newUser);
    }

    // function: 사용자 JWT 생성 메서드 
    public String generateUserJWT(String userIdentifier, String email) {
        try {
            Long now = System.currentTimeMillis();

            JWSHeader header = new JWSHeader(JWSAlgorithm.HS256);

            JWTClaimsSet claims = new JWTClaimsSet.Builder()
                .subject(userIdentifier)
                .claim("email", email)
                .issueTime(new Date(now))
                .expirationTime(new Date(now + 3600 * 1000))
                .build();

            SignedJWT signedJWT = new SignedJWT(header, claims);

            JWSSigner signer = new MACSigner(appleKeyPath);
            signedJWT.sign(signer);

            return signedJWT.serialize();
 
        } catch (Exception e) {
            throw new RuntimeException("사용자 JWT를 생성하지 못했습니다.");
        }
    }

    // function: Apple Login 요청 처리 
    public Map<String, String> handleAppleLogin(String idToken, String appleResponse, String deviceToken) {
        if(!validateAppleToken(idToken)) {
            throw new RuntimeException("유효하지 않은 ID 토큰");
        }

        String email = extractEmailFromToken(idToken); // ID 토큰에서 email 추출 
        String userIdentifier = extractUserIdentifierFromToken(idToken); // ID 토큰에서 사용자 식별자 추출 
        String authorizationCode = extractAuthorizationCodeFromAppleResponse(appleResponse); // 애플의 응답데이터(appleResponse)에서 인증 코드 추출 

        if(authorizationCode == null || authorizationCode.isEmpty()) {
            throw new RuntimeException("인증 코드는 null이거나 비어 있을 수 없습니다.");
        }

        String refreshToken;
        try {
            refreshToken = getRefreshTokenUsingAuthorizationCode(authorizationCode);
        } catch (Exception e) {
            throw new RuntimeException("Refresh token을 찾을 수 없습니다.");
        }

        String encryptedRefreshToken = generateEncryptedRefreshToken(refreshToken);
        Optional<UserEntity> existingUser = userRepository.findByUserIdentifier(userIdentifier); 

        String userUniqueId;
        if(existingUser.isPresent()) {
            UserEntity userEntity = existingUser.get();
            userEntity.setRefreshToken(encryptedRefreshToken);
            userRepository.save(userEntity);
            userUniqueId = userEntity.getUserUniqueId();
        } else  {
            UserEntity newUser = registerUser(userIdentifier, email, encryptedRefreshToken, "apple", "수성", 0);
            userUniqueId = newUser.getUserUniqueId();
        }

        String accessToken; // accessToken 변수 생성 
        try {
            accessToken = getAccessTokenUsingRefreshToken(refreshToken);
        } catch (Exception e) {
            throw new RuntimeException("Access token을 검색하지 못했습니다.");
        }

        String userJWT = generateUserJWT(userIdentifier, email);
  
        return Map.of("userIdentifier", userIdentifier, "refreshToken", accessToken, "userJWT", userJWT, "userUniqueId", userUniqueId);
    }

    // function: ID Token 검증 
    public boolean validateAppleToken(String idToken) {
        try {
            // 1. Apple의 공개 키를 가져옴
            logger.info("URL에서 Apple 공개 키 가져오기: " + applePublicKeyUrl);
            JWKSet publicKeys = JWKSet.load(new URL(applePublicKeyUrl));

            // 2. idToken을 SignedJWT로 파싱
            SignedJWT signedJWT = SignedJWT.parse(idToken);
            
            // 3. 토큰의 헤더에서 keyID 가져오기
            String keyId = signedJWT.getHeader().getKeyID();
            logger.info("Token key ID: " + keyId);

            // 4. keyID와 일치하는 공개 키 검색
            JWK jwk = publicKeys.getKeyByKeyId(keyId);
            if (jwk == null) {
                logger.error("키 ID와 일치하는 키가 없습니다: " + keyId);
                return false; // 일치하는 키가 없으면 검증 실패
            }

            // 5. 공개 키를 사용해 토큰의 서명을 검증
            RSAKey rsaKey = jwk.toRSAKey();
            JWSObject jwsObject = JWSObject.parse(idToken);
            if (!jwsObject.verify(new com.nimbusds.jose.crypto.RSASSAVerifier(rsaKey))) {
                logger.error("토큰 서명 검증에 실패했습니다.");
                return false; // 서명이 올바르지 않으면 검증 실패
            }

            // 6. 토큰의 클레임(Claims) 유효성 확인
            JsonNode claims = new ObjectMapper().readTree(signedJWT.getPayload().toString());
            String issuer = claims.get("iss").asText();
            String audience = claims.get("aud").asText();
            logger.info("Token issuer: " + issuer + ", audience: " + audience);

            if (!appleIss.equals(issuer) || !appleAud.equals(audience)) {
                logger.error("appleIss 또는 appleAud이 일치하지 않습니다. 예상 appleIss: " + appleIss + ", appleAud: " + appleAud);
                return false; // 발행자와 클라이언트 ID가 일치하지 않으면 검증 실패
            }

            // 7. 만료 시간 확인
            long expiration = claims.get("exp").asLong();
            if (System.currentTimeMillis() / 1000 >= expiration) {
                logger.error("Token has expired");
                return false; // 토큰이 만료되었으면 검증 실패
            }

            logger.info("토큰이 유효합니다.");
            return true; // 모든 검증에 성공하면 유효한 토큰
        } catch (ParseException | JOSEException | IOException e) {
            logger.error("토큰 유효성 검사 중 예외가 발생했습니다.", e);
            throw new RuntimeException("유효하지 않은 ID 토큰", e);
        }
    }

    // function: ID Token에서 Email 추출 
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

    // function: ID Token에서 UserIdentifier 추출 
    private String extractUserIdentifierFromToken(String idToken) {
        try {
            JWT jwt = JWTParser.parse(idToken);

            if (jwt instanceof SignedJWT) {
                SignedJWT signedJWT = (SignedJWT) jwt;

                return signedJWT.getJWTClaimsSet().getStringClaim("sub");  
            }
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return null;
    }

    // function: 애플의 응답데이터(appleResponse)에서 인증 코드 추출 
    private String extractAuthorizationCodeFromAppleResponse(String response) {
        JSONObject jsonResponse = new JSONObject(response);

        // authorizationCode 추출
        if (jsonResponse.has("authorizationCode")) {
            return jsonResponse.getString("authorizationCode");
        } else {
            throw new RuntimeException("Apple 응답에서 인증 코드를 찾을 수 없습니다");
        }
    }
    
    // function: 주어진 인증 코드(authorizationCode)를 사용하여 Refresh-Token 획득 
    private String getRefreshTokenUsingAuthorizationCode(String authorizationCode) {
        // 애플의 토큰 엔드포인트
        String tokenUrl = appleAuthTokenUrl;
    
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
                throw new RuntimeException("Apple에서 새로 고침 토큰을 검색하지 못했습니다.");
            }
        } catch (IOException e) {
            throw new RuntimeException("새로 고침 토큰을 요청하는 중 IOException이 발생했습니다.");
        }
    }    

    // function: Refresh Token 암호화 메서드 
    private String generateEncryptedRefreshToken(String refreshToken) {
        try {
            // AES 암호화 사용
            return encryptionUtil.encrypt(refreshToken);
        } catch (Exception e) {
            throw new RuntimeException("Refresh Token 암호화하지 못함", e);
        }
    }

    // function: Refresh Token 복호화 메서드 
    public String decryptRefreshToken(String encryptedToken) {
        try {
            return encryptionUtil.decrypt(encryptedToken);
        } catch (Exception e) {
            throw new RuntimeException("Refresh Token 복호화하지 못함" + e.getMessage(), e);
        }
    }

    // function: 응답 JSON에서 refresh token 추출 
    private String extractRefreshTokenFromResponse(String jsonResponse) {
        JSONObject response = new JSONObject(jsonResponse);

        if (response.has("refresh_token")) {
            return response.getString("refresh_token");
        } else {
            throw new RuntimeException("응답에서 새로 고침 토큰을 찾을 수 없습니다.");
        }
    }

    // function: client secret 생성 
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
                    .audience(appleIss) // Audience
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

    // function: private key 가져오기 
    private PrivateKey getPrivateKey() {
        try {
            // 파일 존재 여부 확인
            File keyFile = new File(appleKeyPath);
            if (!keyFile.exists()) {
                throw new RuntimeException("private key 파일이 존재하지 않습니다: " + appleKeyPath);
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

    // function: 리프레시 토큰을 사용해 액세스 토큰 가져오기 
    public String getAccessTokenUsingRefreshToken(String refreshToken) {
        String tokenEndpoint = appleAuthTokenUrl;
        
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Content-Type", "application/x-www-form-urlencoded");

        String clientSecret = generateClientSecret(); // Client Secret 생성

        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("client_id", appleAud);
        body.add("client_secret", clientSecret);
        body.add("grant_type", "refresh_token");
        body.add("refresh_token", refreshToken);    

        HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(body, headers);
    
        ResponseEntity<Map> responseEntity;
        try {
            System.out.println("Apple에 요청을 보내는 중...");
            responseEntity = restTemplate.postForEntity(tokenEndpoint, requestEntity, Map.class);
            // restTemplate.postForEntity()를 사용하여 POST 요청을 전송하고, 애플의 토큰 엔드포인트에서 응답을 받음
            
            if (responseEntity.getStatusCode() == HttpStatus.OK) {
                return (String) responseEntity.getBody().get("access_token");
            } else {
                throw new RuntimeException("액세스 토큰을 검색하지 못함" + responseEntity.getStatusCode());
            }
        } catch (HttpClientErrorException e) {
            throw new RuntimeException("액세스 토큰을 검색하지 못함" + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("액세스 토큰을 검색하지 못함", e);
        }
    }

    // function: 사용자 탈퇴 처리
    @Transactional
    public void deleteUserAccount(String userIdentifier) {
        // 1. 주어진 userIdentifier로 사용자 정보 찾기
        UserEntity user = userRepository.findByUserIdentifier(userIdentifier)
                                        .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
        System.out.println("user : " + user);
        String userUniqueId = user.getUserUniqueId();
        System.out.println("userUniqueId : " + userUniqueId);
        
        // 2. 관련된 데이터 삭제
        // 2.1 guest_book_favorite 테이블에서 사용자 관련 데이터 삭제
        guestBookFavoriteRepository.deleteByUserUniqueId(user);
        System.out.println("guestBookFavoriteRepository 삭제");
        
        // 2.2 success_count 테이블에서 사용자 관련 데이터 삭제
        successRepository.deleteByUserUniqueId(userUniqueId);
        System.out.println("successRepository 삭제");
        
        // 2.3 guest_book 테이블에서 작성한 게시물 삭제
        guestBookRepository.deleteByAuthor_UserUniqueId(userUniqueId);
        System.out.println("guestBookRepository 삭제");
        
        // 2.4 day_walking 테이블에서 사용자 관련 데이터 삭제
        stepRepository.deleteByUserUniqueId(userUniqueId);
        System.out.println("stepRepository 삭제");
    
        // 3. 사용자 정보 삭제
        userRepository.delete(user);
        System.out.println("userRepository 삭제");
    }
}