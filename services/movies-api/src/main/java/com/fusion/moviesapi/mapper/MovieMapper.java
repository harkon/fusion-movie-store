package com.fusion.moviesapi.mapper;

import com.fusion.moviesapi.entity.*;
import com.fusion.moviesapi.model.MovieDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring", uses = {ActorMapper.class, GenreMapper.class})
public interface MovieMapper {
    List<MovieDTO> toDTOList(List<Movie> movies);
    List<Movie> toEntityList(List<MovieDTO> movieDTOs);
    MovieDTO toDTO(Movie movie);
    Movie toEntity(MovieDTO movieDTO);
}
