package com.spacewanderer.space_back.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.SuccessEntity;

@Repository
public interface SuccessRepository extends JpaRepository<SuccessEntity, Long> {
    // 특정 사용자의 특정 날짜 성공 기록을 확인하기 위한 메서드
    boolean existsByUserUniqueIdAndDayId(String userUniqueId, Long dayId);
        
    // 특정 사용자의 성공 기록 개수를 조회하기 위한 메서드
    long countByUserUniqueId(String userUniqueId);

    // 회원 탈퇴 시 특정 사용자의 데이터를 삭제하기 위한 메서드
    long deleteByUserUniqueId(String userUniqueId);
}
