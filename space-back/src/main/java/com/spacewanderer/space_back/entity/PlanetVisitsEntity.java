package com.spacewanderer.space_back.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Getter
@Setter
@NoArgsConstructor
@Entity(name = "planet_visits")
@Table(name = "planet_visits")
public class PlanetVisitsEntity {
    // 행성 ID (Primary Key)
    @Id
    @Column(name = "planet_id")
    private Long planetId; // planetId를 기본 키로 설정

    // 행성 이름
    @Column(name = "planet")
    private String planet;

    // 방문 횟수
    @Column(name = "visits_number")
    private int visitsNumber;

    // 첫 방문 날짜
    @Column(name = "first_visit_date")
    private LocalDate firstVisitDate;

    // 방문자 별명
    @Column(name = "visits_nickname")
    private String visitsNickname;

    // 사용자 고유 ID
    @Column(name = "user_unique_id")
    private String userUniqueId;
}