package com.spacewanderer.space_back.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.GuestBookEntity;

@Repository
public interface GuestBookRepository extends JpaRepository<GuestBookEntity, Long> {
    // 회원 탈퇴 시 특정 사용자의 방명록 데이터를 삭제하기 위한 메서드
    long deleteByAuthor_UserUniqueId(String userUniqueId); // 중첩 속성 사용
}
