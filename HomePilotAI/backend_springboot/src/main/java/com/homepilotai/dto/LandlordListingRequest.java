package com.homepilotai.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

public record LandlordListingRequest(
        @NotBlank String title,
        @NotNull @Positive BigDecimal price,
        @NotBlank String location,
        @NotNull @Positive Integer bedrooms,
        @NotNull @Positive Integer bathrooms,
        @NotBlank String rentOrBuy,   // "RENT" or "BUY"
        String description,
        String imageUrl
) {
}
