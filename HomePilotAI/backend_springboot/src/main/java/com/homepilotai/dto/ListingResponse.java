package com.homepilotai.dto;

import com.homepilotai.models.Listing;
import com.homepilotai.models.RentOrBuyPreference;
import java.math.BigDecimal;

public record ListingResponse(
        Long id,
        String title,
        BigDecimal price,
        String location,
        Integer bedrooms,
        Integer bathrooms,
        RentOrBuyPreference rentOrBuy,
        String description,
        String imageUrl,
        Long landlordId
) {

    public static ListingResponse from(Listing listing) {
        return new ListingResponse(
                listing.getId(),
                listing.getTitle(),
                listing.getPrice(),
                listing.getLocation(),
                listing.getBedrooms(),
                listing.getBathrooms(),
                listing.getRentOrBuy(),
                listing.getDescription(),
                listing.getImageUrl(),
                listing.getLandlordId()
        );
    }
}
