package com.fusion.moviesapi.mapper;

import com.fusion.moviesapi.entity.Track;
import com.fusion.moviesapi.model.TrackDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface TrackMapper {

    @Mapping(source = "artist.id", target = "artistId")
    TrackDTO toDTO(Track track);

    @Mapping(target = "artist", ignore = true)
    Track toEntity(TrackDTO dto);
}
