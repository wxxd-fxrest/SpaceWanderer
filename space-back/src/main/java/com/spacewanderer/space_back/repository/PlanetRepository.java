package com.spacewanderer.space_back.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spacewanderer.space_back.entity.PlanetEntity;

@Repository
public interface PlanetRepository extends JpaRepository<PlanetEntity, String> {
    Optional<PlanetEntity> findByName(String name);
}