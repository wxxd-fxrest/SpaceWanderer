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
@Table(name = "day_walking")
@Entity(name = "day_walking")
public class StepEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "day_id")  // MySQL의 `day_id` 컬럼과 매핑
    private Long dayId;

    @Column(name = "day_destination")  // MySQL의 `day_id` 컬럼과 매핑
    private String dayDestination;
    private String walkingDate;
    private int daySteps;
    private boolean dayGoal;
    private String userUniqueId;  // 사용자 고유 ID

    public StepEntity(Long dayId, String dayDestination, String walkingDate, int daySteps, boolean dayGoal, String userUniqueId) {
        this.dayId = dayId;
        this.dayDestination = dayDestination;
        this.walkingDate = walkingDate;
        this.daySteps = daySteps;
        this.dayGoal = dayGoal;
        this.userUniqueId = userUniqueId;
    }

    public String getWalkingDate() {
        return walkingDate;
    }

    public String getDayDestination() {
        return dayDestination;
    }
}
