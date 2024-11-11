package com.spacewanderer.space_back.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.StepEntity;

@Repository
public interface StepRepository extends JpaRepository<StepEntity, Long> {
  // 사용자 고유 ID와 날짜로 걸음 수 데이터를 찾기
    StepEntity findByUserUniqueIdAndWalkingDate(String userUniqueId, String walkingDate);
    
    // 최신 기록된 날짜를 가져오기
    StepEntity findTopByUserUniqueIdOrderByWalkingDateDesc(String userUniqueId);
}
