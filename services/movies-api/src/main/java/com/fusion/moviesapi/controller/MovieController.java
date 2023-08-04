package com.fusion.moviesapi.controller;

import com.fusion.moviesapi.model.MovieDTO;
import com.fusion.moviesapi.service.MovieService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/movies")
public class MovieController {

    private final MovieService movieService;

    @Autowired
    public MovieController(MovieService movieService) {
        this.movieService = movieService;
    }

    @GetMapping("/year/{year}")
    public ResponseEntity<List<MovieDTO>> getMoviesByYear(@PathVariable int year) {
        List<MovieDTO> movies = movieService.findByYear(year);
        return ResponseEntity.ok(movies);
    }


    @GetMapping("/title/{title}")
    public ResponseEntity<List<MovieDTO>> findByTitle(@PathVariable String title) {
        List<MovieDTO> movies = movieService.findByTitle(title);
        return ResponseEntity.ok(movies);
    }

    @GetMapping("/actor/{name}")
    public ResponseEntity<List<MovieDTO>> findByActor(@PathVariable String name) {
        List<MovieDTO> movies = movieService.findByActor(name);
        return ResponseEntity.ok(movies);
    }

    @GetMapping("/genre/{name}")
    public ResponseEntity<List<MovieDTO>> findByGenre(@PathVariable String name) {
        List<MovieDTO> movies = movieService.findByGenre(name);
        return ResponseEntity.ok(movies);
    }
}
