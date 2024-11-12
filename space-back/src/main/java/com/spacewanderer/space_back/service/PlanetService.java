package com.spacewanderer.space_back.service;

import java.util.Arrays;
import java.util.List;

import org.springframework.stereotype.Service;

import com.spacewanderer.space_back.entity.PlanetEntity;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PlanetService {

    // private final UserRepository userRepository;
    // private final PlanetRepository planetRepository;

    
    public List<PlanetEntity> getAllPlanets() {
        return Arrays.asList(
            new PlanetEntity("01", "Mercury", "Closest planet to the Sun.", "https://example.com/mercury.png", 5),
            new PlanetEntity("02", "Venus", "Second planet from the Sun.", "https://example.com/venus.png", 10),
            new PlanetEntity("03", "Earth", "Our home planet.", "https://example.com/earth.png", 10),
            new PlanetEntity("04", "Mars", "Known as the Red Planet.", "https://example.com/mars.png", 10),
            new PlanetEntity("05", "Jupiter", "Largest planet in the Solar System.", "https://example.com/jupiter.png", 10),
            new PlanetEntity("06", "Saturn", "Famous for its rings.", "https://example.com/saturn.png", 10),
            new PlanetEntity("07", "Uranus", "An ice giant with a unique tilt.", "https://example.com/uranus.png", 10),
            new PlanetEntity("08", "Neptune", "The farthest planet from the Sun.", "https://example.com/neptune.png", 10)
        );
    }    
}
