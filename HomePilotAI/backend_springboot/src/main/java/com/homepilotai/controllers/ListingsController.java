package com.homepilotai.controllers;

import com.homepilotai.dto.FavoriteRequest;
import com.homepilotai.dto.ListingResponse;
import com.homepilotai.models.RentOrBuyPreference;
import com.homepilotai.services.ListingService;
import com.homepilotai.services.SavedPropertyService;
import com.homepilotai.services.UserProfileService;
import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ListingsController {

    private final ListingService listingService;
    private final SavedPropertyService savedPropertyService;
    private final UserProfileService userProfileService;

    @GetMapping("/listings")
    public List<ListingResponse> getListings(
            @RequestParam(required = false) String location,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) RentOrBuyPreference rentOrBuy
    ) {
        return listingService.getListings(location, maxPrice, rentOrBuy);
    }

    @GetMapping("/listings/{id}")
    public ListingResponse getListing(@PathVariable Long id) {
        return listingService.getListing(id);
    }

    @PostMapping("/favorites")
    @ResponseStatus(HttpStatus.CREATED)
    public void saveFavorite(Authentication authentication, @Valid @RequestBody FavoriteRequest request) {
        var user = userProfileService.getCurrentUser(authentication);
        var listing = listingService.getListingEntity(request.listingId());
        savedPropertyService.saveFavorite(user, listing);
    }

    @GetMapping("/favorites")
    public List<ListingResponse> getFavorites(Authentication authentication) {
        return savedPropertyService.getSavedProperties(userProfileService.getCurrentUser(authentication));
    }
}
