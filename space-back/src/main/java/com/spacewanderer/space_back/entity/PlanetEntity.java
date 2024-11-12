package com.spacewanderer.space_back.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class PlanetEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private String id;
    private String name;
    private String description;
    private String imageUrl;
    private int requiredSteps;  // 이 행성을 방문하기 위해 필요한 만보기 성공 횟수

    public PlanetEntity(String id, String name, String description, String imageUrl, int requiredSteps) {
        this.id = id; 
        this.name = name;
        this.description = description;
        this.imageUrl = imageUrl;
        this.requiredSteps = requiredSteps;
    }

    // Getter와 Setter 메서드 추가
    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public int getRequiredSteps() {
        return requiredSteps;
    }
}
