package com.spacewanderer.space_back.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.GuestBookFavoriteEntity;
import com.spacewanderer.space_back.entity.UserEntity;

@Repository
public interface GuestBookFavoriteRepository extends JpaRepository<GuestBookFavoriteEntity, Long> {
    // UserEntity의 userUniqueId를 사용하여 삭제
    long deleteByUserUniqueId(UserEntity user);
}
