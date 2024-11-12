package com.spacewanderer.space_back.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.entity.PlanetEntity;
import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.repository.UserRepository;
import com.spacewanderer.space_back.service.PlanetService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/planet")
@RequiredArgsConstructor
public class PlanetController {

    private final PlanetService planetService;
    private final UserRepository userRepository;

    @GetMapping("/get-all-planet")
    public ResponseEntity<List<PlanetEntity>> getPlanets() {
        List<PlanetEntity> planets = planetService.getAllPlanets();
        return ResponseEntity.ok(planets);
    }
}
