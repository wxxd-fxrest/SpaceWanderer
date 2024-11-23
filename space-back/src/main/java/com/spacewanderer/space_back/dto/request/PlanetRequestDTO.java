package com.spacewanderer.space_back.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PlanetRequestDTO {
    private String name;
    private String description;
    private String planetImage;
    private int stepsRequired;

    public PlanetRequestDTO(String name, String description, String planetImage, int stepsRequired) {
        this.name = name;
        this.description = description;
        this.planetImage = planetImage;
        this.stepsRequired = stepsRequired;
    }
}
