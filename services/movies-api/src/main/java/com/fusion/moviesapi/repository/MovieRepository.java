package com.fusion.moviesapi.repository;

import com.fusion.moviesapi.entity.Movie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

//@Repository
public interface MovieRepository extends JpaRepository<Movie, Long> {

    @Query("SELECT m FROM Movie m WHERE m.year = :year")
    List<Movie> findByYear(@Param("year") int year);

    @Query("SELECT m FROM Movie m WHERE m.title LIKE %:title%")
    List<Movie> findByTitle(@Param("title") String title);

    @Query(value = "SELECT m FROM Movie m JOIN m.actors a WHERE a.name LIKE %:name%")
    List<Movie> findByActor(@Param("name") String name);

    @Query(value = "SELECT m FROM Movie m JOIN m.genres g WHERE g.name LIKE %:name%")
    List<Movie> findByGenre(@Param("name") String name);

}


