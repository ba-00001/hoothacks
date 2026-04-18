package com.homepilotai.controllers;

import com.homepilotai.dto.LandlordListingRequest;
import com.homepilotai.dto.ListingResponse;
import com.homepilotai.models.AppUser;
import com.homepilotai.models.Listing;
import com.homepilotai.models.RentOrBuyPreference;
import com.homepilotai.repositories.ListingRepository;
import com.homepilotai.services.UserProfileService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/landlord")
@RequiredArgsConstructor
public class LandlordController {

    private final ListingRepository listingRepository;
    private final UserProfileService userProfileService;

    @GetMapping("/listings")
    public List<ListingResponse> getMyListings(Authentication authentication) {
        AppUser landlord = userProfileService.getCurrentUser(authentication);
        return listingRepository.findAll().stream()
                .filter(l -> landlord.getId().equals(l.getLandlordId()))
                .map(ListingResponse::from)
                .toList();
    }

    @PostMapping("/listings")
    @ResponseStatus(HttpStatus.CREATED)
    public ListingResponse createListing(
            Authentication authentication,
            @Valid @RequestBody LandlordListingRequest request
    ) {
        AppUser landlord = userProfileService.getCurrentUser(authentication);
        Listing listing = listingRepository.save(Listing.builder()
                .title(request.title())
                .price(request.price())
                .location(request.location())
                .bedrooms(request.bedrooms())
                .bathrooms(request.bathrooms())
                .rentOrBuy(RentOrBuyPreference.valueOf(request.rentOrBuy()))
                .description(request.description())
                .imageUrl(request.imageUrl())
                .landlordId(landlord.getId())
                .build());
        return ListingResponse.from(listing);
    }

    @PutMapping("/listings/{id}")
    public ListingResponse updateListing(
            Authentication authentication,
            @PathVariable Long id,
            @Valid @RequestBody LandlordListingRequest request
    ) {
        AppUser landlord = userProfileService.getCurrentUser(authentication);
        Listing listing = listingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found"));
        if (!landlord.getId().equals(listing.getLandlordId())) {
            throw new IllegalArgumentException("You do not own this listing");
        }
        listing.setTitle(request.title());
        listing.setPrice(request.price());
        listing.setLocation(request.location());
        listing.setBedrooms(request.bedrooms());
        listing.setBathrooms(request.bathrooms());
        listing.setRentOrBuy(RentOrBuyPreference.valueOf(request.rentOrBuy()));
        listing.setDescription(request.description());
        listing.setImageUrl(request.imageUrl());
        return ListingResponse.from(listingRepository.save(listing));
    }

    @DeleteMapping("/listings/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteListing(Authentication authentication, @PathVariable Long id) {
        AppUser landlord = userProfileService.getCurrentUser(authentication);
        Listing listing = listingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found"));
        if (!landlord.getId().equals(listing.getLandlordId())) {
            throw new IllegalArgumentException("You do not own this listing");
        }
        listingRepository.delete(listing);
    }
}
