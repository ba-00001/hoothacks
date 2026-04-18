package com.homepilot.app.models;

import jakarta.persistence.*;

@Entity
@Table(name = "recommendations")
public class Recommendation {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long listingId;

    @Column(nullable = false)
    private Double score;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Long getListingId() { return listingId; }
    public void setListingId(Long listingId) { this.listingId = listingId; }
    public Double getScore() { return score; }
    public void setScore(Double score) { this.score = score; }
}
