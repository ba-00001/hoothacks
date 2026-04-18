package com.homepilotai.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "listings")
public class Listing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private BigDecimal price;
    private String location;
    private Integer bedrooms;
    private Integer bathrooms;

    @Enumerated(EnumType.STRING)
    private RentOrBuyPreference rentOrBuy;

    @Column(length = 1000)
    private String description;

    private String imageUrl;

    // null = seeded/platform listing; non-null = submitted by a landlord/agent
    private Long landlordId;
}
