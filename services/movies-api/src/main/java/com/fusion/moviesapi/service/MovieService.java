package com.fusion.moviesapi.service;

import com.fusion.moviesapi.entity.Movie;
import com.fusion.moviesapi.mapper.MovieMapper;
import com.fusion.moviesapi.model.MovieDTO;
import com.fusion.moviesapi.repository.MovieRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MovieService {

    private final MovieRepository movieRepository;
    private final MovieMapper movieMapper;

    public MovieService(MovieRepository movieRepository, MovieMapper movieMapper) {
        this.movieRepository = movieRepository;
        this.movieMapper = movieMapper;
    }

    @Cacheable(value = "movies", key = "#year")
    public List<MovieDTO> findByYear(int year) {
        List<Movie> movies = movieRepository.findByYear(year);
        return movieMapper.toDTOList(movies);
    }

    @Cacheable(value = "movies", key = "#title")
    public List<MovieDTO> findByTitle(String title) {
        List<Movie> movies = movieRepository.findByTitle(title);
        return movieMapper.toDTOList(movies);
    }

    @Cacheable(value = "movies", key = "#actorName")
    public List<MovieDTO> findByActor(String actorName) {
        List<Movie> movies = movieRepository.findByActor(actorName);
        return movieMapper.toDTOList(movies);
    }

    @Cacheable(value = "movies", key = "#genreName")
    public List<MovieDTO> findByGenre(String genreName) {
        List<Movie> movies = movieRepository.findByGenre(genreName);
        return movieMapper.toDTOList(movies);
    }

}
