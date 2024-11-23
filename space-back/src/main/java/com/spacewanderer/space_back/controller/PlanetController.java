package com.spacewanderer.space_back.controller;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.dto.response.PlanetResponseDTO;
import com.spacewanderer.space_back.entity.PlanetEntity;
import com.spacewanderer.space_back.service.PlanetService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/planet")
@RequiredArgsConstructor
public class PlanetController {

    private final PlanetService planetService;

    @GetMapping("/get-all-planet")
    public ResponseEntity<List<PlanetResponseDTO>> getPlanets() {
        List<PlanetEntity> planets = planetService.getAllPlanets();
        
        // Convert Entity to DTO
        List<PlanetResponseDTO> planetResponseDTOs = planets.stream()
            .map(planet -> new PlanetResponseDTO(planet.getId(), planet.getName(), planet.getDescription(), planet.getPlanetImage(), planet.getStepsRequired()))
            .collect(Collectors.toList());
            
        for (PlanetEntity planet : planets) {
            System.out.println("Planet: " + planet.getName() + ", Distance from Sun: " + planet.getDescription() + "");
        }
        return ResponseEntity.ok(planetResponseDTOs);
    }
}
