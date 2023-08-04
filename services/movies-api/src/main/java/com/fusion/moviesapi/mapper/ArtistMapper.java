package com.fusion.moviesapi.mapper;

import com.fusion.moviesapi.entity.Artist;
import com.fusion.moviesapi.entity.Track;
import com.fusion.moviesapi.model.ArtistDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface ArtistMapper {

    @Mapping(source = "tracks", target = "tracksIds")
    ArtistDTO toDTO(Artist artist);

    @Mapping(target = "tracks", ignore = true)
    Artist toEntity(ArtistDTO dto);

    default List<Long> mapTracks(List<Track> tracks) {
        return tracks.stream()
                .map(Track::getId)
                .collect(Collectors.toList());
    }
}
