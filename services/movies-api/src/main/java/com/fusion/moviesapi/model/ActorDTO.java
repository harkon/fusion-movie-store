package com.fusion.moviesapi.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;
//import org.hibernate.cache.redis.hi
@Data
public class ActorDTO implements Serializable {
    @JsonProperty
    private Long actorId;
    @JsonProperty
    private String name;
}