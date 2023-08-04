package com.fusion.moviesapi.repository;

import com.fusion.moviesapi.entity.Track;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TrackRepository extends JpaRepository<Track, Long> {

    @Query("SELECT t FROM Track t WHERE t.artist.id = ?1")
    List<Track> findAllByArtistId(Long artistId);

    @Query("SELECT t FROM Track t WHERE t.genre = ?1")
    List<Track> findAllByGenre(String genre);
}
