package com.spacewanderer.space_back.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.UserEntity;

@Repository
public interface UserRepository extends JpaRepository<UserEntity, String> {
    Optional<UserEntity> findByUserIdentifier(String userIdentifier);  // userIdentifier로 유저 찾기
    Optional<UserEntity> findByNickname(String nickname);
    Optional<UserEntity> findByUserUniqueId(String userUniqueId);
    void deleteByUserIdentifier(String userIdentifier);
}
