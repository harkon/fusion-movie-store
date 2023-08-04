package com.fusion.moviesapi.service;

import com.fusion.moviesapi.entity.Artist;
import com.fusion.moviesapi.entity.Track;
import com.fusion.moviesapi.mapper.ArtistMapper;
import com.fusion.moviesapi.mapper.TrackMapper;
import com.fusion.moviesapi.model.ArtistDTO;
import com.fusion.moviesapi.model.TrackDTO;
import com.fusion.moviesapi.repository.ArtistRepository;
import com.fusion.moviesapi.repository.TrackRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MusicService {
    private final ArtistRepository artistRepository;
    private final TrackRepository trackRepository;
    private final ArtistMapper artistMapper;
    private final TrackMapper trackMapper;

    public MusicService(ArtistRepository artistRepository,
                        TrackRepository trackRepository,
                        ArtistMapper artistMapper,
                        TrackMapper trackMapper) {
        this.artistRepository = artistRepository;
        this.trackRepository = trackRepository;
        this.artistMapper = artistMapper;
        this.trackMapper = trackMapper;
    }

    public TrackDTO addTrack(TrackDTO trackDTO) {
        Artist artist = artistRepository.findById(trackDTO.getArtistId())
                .orElseThrow(() -> new RuntimeException("Artist not found with id: " + trackDTO.getArtistId()));

        Track track = this.trackMapper.toEntity(trackDTO);
        track.setArtist(artist);

        Track savedTrack = this.trackRepository.save(track);
        return trackMapper.toDTO(savedTrack);
    }

    public ArtistDTO editArtist(Long id, ArtistDTO artistDTO) {
        Artist artist = artistRepository.findById(id).orElseThrow(() -> new RuntimeException("Artist not found with id: " + id));
        artist.setName(artistDTO.getName());
        Artist savedArtist = artistRepository.save(artist);
        return artistMapper.toDTO(savedArtist);
    }

    @Cacheable(value = "music", key = "#artist")
    public List<TrackDTO> getAllTracksByArtist(Long artistId) {
        List<Track> tracks = trackRepository.findAllByArtistId(artistId);
        return tracks.stream()
                .map(trackMapper::toDTO)
                .collect(Collectors.toList());
    }

    
    public List<TrackDTO> getAllTracksByGenre(String genre) {
        List<Track> tracks = trackRepository.findAllByGenre(genre);
        return tracks.stream()
                .map(trackMapper::toDTO)
                .collect(Collectors.toList());
    }

    @Cacheable(value = "music", key = "#artist_of_day")
    public ArtistDTO fetchArtistOfTheDay() {
        // Fetch artist of the day, convert to DTO
        // TODO: 
        return null;
    }
}
