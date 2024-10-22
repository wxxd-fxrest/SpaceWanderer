package com.spacewanderer.space_back.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.spacewanderer.space_back.entity.UserEntity;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, String> {
    Optional<UserEntity> findByUserIdentifier(String userIdentifier);  // userIdentifier로 유저 찾기
}
