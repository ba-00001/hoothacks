package com.homepilotai.services;

import com.homepilotai.dto.ListingResponse;
import com.homepilotai.models.AppUser;
import com.homepilotai.models.SavedProperty;
import com.homepilotai.repositories.SavedPropertyRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SavedPropertyService {

    private final SavedPropertyRepository savedPropertyRepository;

    public List<ListingResponse> getSavedProperties(AppUser user) {
        return savedPropertyRepository.findByUserId(user.getId()).stream()
                .map(savedProperty -> ListingResponse.from(savedProperty.getListing()))
                .toList();
    }

    public void saveFavorite(AppUser user, com.homepilotai.models.Listing listing) {
        savedPropertyRepository.findByUserIdAndListingId(user.getId(), listing.getId())
                .orElseGet(() -> savedPropertyRepository.save(SavedProperty.builder()
                        .user(user)
                        .listing(listing)
                        .build()));
    }
}
