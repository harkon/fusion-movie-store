package com.fusion.moviesapi.mapper;

import com.fusion.moviesapi.entity.Genre;
import com.fusion.moviesapi.model.GenreDTO;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface GenreMapper {
    GenreDTO toDTO(Genre genre);
    Genre toEntity(GenreDTO genreDTO);
    List<GenreDTO> toDTOList(List<Genre> genres);
    List<Genre> toEntityList(List<GenreDTO> genreDTOs);
}
