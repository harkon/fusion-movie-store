package com.fusion.moviesapi.util;

import com.fusion.moviesapi.entity.Artist;
import com.fusion.moviesapi.entity.Track;
import com.fusion.moviesapi.repository.ArtistRepository;
import com.fusion.moviesapi.repository.TrackRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;


@Component
public class DataLoader implements CommandLineRunner {

    private final ArtistRepository artistRepository;
    private final TrackRepository trackRepository;

    public DataLoader(ArtistRepository artistRepository, TrackRepository trackRepository) {
        this.artistRepository = artistRepository;
        this.trackRepository = trackRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        if (artistRepository.count() == 0 && trackRepository.count() == 0) {
            Artist artist1 = new Artist();
            artist1.setName("Artist 1");

            Artist artist2 = new Artist();
            artist2.setName("Artist 2");

            artistRepository.save(artist1);
            artistRepository.save(artist2);

            Track track1 = new Track();
            track1.setTitle("Track 1");
            track1.setGenre("Genre 1");
            track1.setLength(300);
            track1.setArtist(artist1);

            Track track2 = new Track();
            track2.setTitle("Track 2");
            track2.setGenre("Genre 2");
            track2.setLength(200);
            track2.setArtist(artist1);

            Track track3 = new Track();
            track3.setTitle("Track 3");
            track3.setGenre("Genre 3");
            track3.setLength(250);
            track3.setArtist(artist2);

            trackRepository.save(track1);
            trackRepository.save(track2);
            trackRepository.save(track3);
        }
    }
}

