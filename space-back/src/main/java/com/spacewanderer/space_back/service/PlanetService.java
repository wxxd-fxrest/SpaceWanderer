package com.spacewanderer.space_back.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.spacewanderer.space_back.entity.PlanetEntity;
import com.spacewanderer.space_back.repository.PlanetRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PlanetService {

    private final PlanetRepository planetRepository;

    public List<PlanetEntity> getAllPlanets() {
        return planetRepository.findAll();
    }
}
