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
@Table(name = "success_count")
@Entity(name = "success_count")
public class SuccessEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "count_id") // MySQL의 count_id 컬럼과 매핑
    private Long countId;

    @Column(name = "day_id") // StepEntity의 day_id와 매핑되는 필드
    private Long dayId;

    @Column(name = "user_unique_id") // 사용자 고유 ID
    private String userUniqueId;

    public SuccessEntity(Long dayId, String userUniqueId) {
        this.dayId = dayId;
        this.userUniqueId = userUniqueId;
    }
}
