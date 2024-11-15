package com.spacewanderer.space_back.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.StepEntity;

@Repository
public interface StepRepository extends JpaRepository<StepEntity, Long> {
  // 사용자 고유 ID와 날짜로 하나의 StepEntity를 찾기
  StepEntity findByUserUniqueIdAndWalkingDate(String userUniqueId, String walkingDate);

  // 사용자 고유 ID와 날짜로 여러 개의 StepEntity를 찾기
  List<StepEntity> findAllByUserUniqueIdAndWalkingDate(String userUniqueId, String walkingDate);

  // 날짜 범위로 검색
  List<StepEntity> findAllByUserUniqueIdAndWalkingDateBetween(String userUniqueId, String startDate, String endDate);
  
  // 최신 기록된 날짜를 가져오기
  StepEntity findTopByUserUniqueIdOrderByWalkingDateDesc(String userUniqueId);
}
