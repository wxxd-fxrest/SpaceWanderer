package com.spacewanderer.space_back.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity(name = "planet")
@Table(name = "planet")
public class PlanetEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "planet_id")  // DB의 planet_id 컬럼을 명시적으로 매핑
    private String id;  // ID는 Long 타입이 일반적입니다.

    private String name;
    private String description;
    private String planetImage;
    private int stepsRequired;  // 이 행성을 방문하기 위해 필요한 만보기 성공 횟수
    
    public PlanetEntity(String name, String description, String planetImage, int stepsRequired) {
        this.name = name;
        this.description = description;
        this.planetImage = planetImage;
        this.stepsRequired = stepsRequired;
    }
}
