package com.fusion.moviesapi.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
public class Track {

    @Id
    @GeneratedValue(strategy= GenerationType.IDENTITY)
    private Long id;
    private String title;
    private String genre;
    private int length;

    @ManyToOne
    @JoinColumn(name="artist_id", nullable=false)
    private Artist artist;
}