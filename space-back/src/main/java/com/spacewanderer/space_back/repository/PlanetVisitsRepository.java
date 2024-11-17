package com.spacewanderer.space_back.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.PlanetVisitsEntity;

@Repository
public interface PlanetVisitsRepository extends JpaRepository<PlanetVisitsEntity, Long> {
    // 회원 탈퇴 시 특정 사용자의 데이터를 삭제하기 위한 메서드
    long deleteByUserUniqueId(String userUniqueId);
}
