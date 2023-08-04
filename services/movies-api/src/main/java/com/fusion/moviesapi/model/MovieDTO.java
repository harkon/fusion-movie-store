package com.fusion.moviesapi.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fusion.moviesapi.entity.Actor;
import com.fusion.moviesapi.entity.Genre;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

@Data
public class MovieDTO implements Serializable {

    @JsonProperty
    private Long movieId;

    @JsonProperty
    private String title;

    @JsonProperty
    private int year;

    @JsonProperty
    private List<ActorDTO> actors;

    @JsonProperty
    private List<GenreDTO> genres;

    @JsonProperty
    private String extract;

    @JsonProperty
    private String href;

    @JsonProperty
    private String thumbnail;

    @JsonProperty
    private int thumbnailWidth;

    @JsonProperty
    private int thumbnailHeight;
}