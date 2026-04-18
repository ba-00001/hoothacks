package com.homepilotai.services;

import com.homepilotai.dto.ListingResponse;
import com.homepilotai.models.Listing;
import com.homepilotai.models.RentOrBuyPreference;
import com.homepilotai.repositories.ListingRepository;
import java.math.BigDecimal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ListingService {

    private final ListingRepository listingRepository;

    public List<ListingResponse> getListings(String location, BigDecimal maxPrice, RentOrBuyPreference rentOrBuy) {
        return listingRepository.findAll().stream()
                .filter(listing -> location == null || listing.getLocation().toLowerCase().contains(location.toLowerCase()))
                .filter(listing -> maxPrice == null || listing.getPrice().compareTo(maxPrice) <= 0)
                .filter(listing -> rentOrBuy == null || listing.getRentOrBuy() == rentOrBuy)
                .map(ListingResponse::from)
                .toList();
    }

    public ListingResponse getListing(Long id) {
        return ListingResponse.from(getListingEntity(id));
    }

    public Listing getListingEntity(Long id) {
        return listingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found"));
    }

    public List<Listing> getAllListings() {
        return listingRepository.findAll();
    }
}
