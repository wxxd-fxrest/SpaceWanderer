package com.spacewanderer.space_back.dto.response;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PlanetResponseDTO {
    private String id;
    private String name;
    private String description;
    private String planetImage;
    private int stepsRequired;

    public PlanetResponseDTO(String id, String name, String description, String planetImage, int stepsRequired) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.planetImage = planetImage;
        this.stepsRequired = stepsRequired;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getPlanetImage() {
        return planetImage;
    }

    public int getStepsRequired() {
        return stepsRequired;
    }
}
