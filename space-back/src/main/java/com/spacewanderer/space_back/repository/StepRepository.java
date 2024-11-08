package com.spacewanderer.space_back.repository;

import java.time.LocalDate;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.StepEntity;

@Repository
public interface StepRepository extends JpaRepository<StepEntity, Long> {
    Optional<StepEntity> findByUserUniqueIdAndWalkingDate(String userUniqueId, LocalDate walkingDate);
}
