package com.fusion.moviesapi.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;

@Data
public class GenreDTO implements Serializable {
    @JsonProperty
    private Long genreId;
    @JsonProperty
    private String name;
}
