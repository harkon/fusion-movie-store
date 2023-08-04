package com.fusion.moviesapi.controller;

import com.fusion.moviesapi.model.ArtistDTO;
import com.fusion.moviesapi.model.TrackDTO;
import com.fusion.moviesapi.service.MusicService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
class MusicController {
    private final MusicService musicService;

    public MusicController(MusicService musicService) {
        this.musicService = musicService;
    }
    @PostMapping("/tracks")
    public ResponseEntity<TrackDTO> addNewTrack(@RequestBody TrackDTO track) {
        TrackDTO trackDTO = musicService.addTrack(track);
        return ResponseEntity.status(HttpStatus.CREATED).body(trackDTO);
    }

    @PutMapping("/artists/{id}")
    public ResponseEntity<ArtistDTO> editArtistName(@PathVariable Long id, @RequestBody ArtistDTO artist) {
        ArtistDTO artistDTO = musicService.editArtist(id, artist);
        return ResponseEntity.ok(artistDTO);
    }

    @GetMapping("/artists/{id}/tracks")
    public ResponseEntity<List<TrackDTO>> fetchArtistTracks(@PathVariable Long id) {
        List<TrackDTO> tracks = musicService.getAllTracksByArtist(id);
        return ResponseEntity.ok(tracks);
    }

    @GetMapping("/artistOfTheDay")
    public ResponseEntity<ArtistDTO> fetchArtistOfTheDay() {
        ArtistDTO artist = musicService.fetchArtistOfTheDay();
        return ResponseEntity.ok(artist);
    }
}
