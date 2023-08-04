package com.fusion.moviesapi.mapper;


import com.fusion.moviesapi.entity.Actor;
import com.fusion.moviesapi.model.ActorDTO;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ActorMapper {
    ActorDTO toDTO(Actor actor);
    Actor toEntity(ActorDTO actorDTO);
    List<ActorDTO> toDTOList(List<Actor> actors);
    List<Actor> toEntityList(List<ActorDTO> actorDTOs);
}
