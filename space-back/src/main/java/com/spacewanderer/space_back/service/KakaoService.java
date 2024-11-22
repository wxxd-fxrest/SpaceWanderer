package com.spacewanderer.space_back.service;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.GuestBookFavoriteRepository;
import com.spacewanderer.space_back.repository.GuestBookRepository;
import com.spacewanderer.space_back.repository.StepRepository;
import com.spacewanderer.space_back.repository.SuccessRepository;
import com.spacewanderer.space_back.repository.UserRepository;
import com.spacewanderer.space_back.utils.EncryptionUtil;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KakaoService {
    private final UserRepository userRepository;
    private final GuestBookFavoriteRepository guestBookFavoriteRepository;
    private final GuestBookRepository guestBookRepository;
    private final SuccessRepository successRepository;
    private final StepRepository stepRepository;
    private final EncryptionUtil encryptionUtil;

    @Value("${kakao.token.url}")
    private String kakaoTokenUrl;

    @Value("${kakao.redirect.url}")
    private String kakaoRedirectUrl;

    @Value("${kakao.rest.api.key}")
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

        UserEntity newUser = new UserEntity(userUniqueId, userIdentifier, email, encryptedRefreshToken, loginType, "수성", 0);
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

    // function: 회원 탈퇴 
    @Transactional
    public void deleteKakaoAccount(String userIdentifier) {
        UserEntity user = userRepository.findByUserIdentifier(userIdentifier)
                                        .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
        String userUniqueId = user.getUserUniqueId(); // userUniqueId를 가져옵니다.
        System.out.println("user : " + user);
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
