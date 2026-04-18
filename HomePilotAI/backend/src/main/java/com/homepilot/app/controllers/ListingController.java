package com.homepilot.app.controllers;

import com.homepilot.app.models.Listing;
import com.homepilot.app.models.SavedProperty;
import com.homepilot.app.repositories.ListingRepository;
import com.homepilot.app.repositories.SavedPropertyRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/listings")
public class ListingController {

    @Autowired private ListingRepository listingRepository;
    @Autowired private SavedPropertyRepository savedPropertyRepository;

    @GetMapping
    public List<Listing> getAll(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) BigDecimal maxPrice) {
        if (type != null && maxPrice != null) {
            return listingRepository.findByTypeAndMaxPrice(type, maxPrice);
        } else if (type != null) {
            return listingRepository.findByType(type);
        } else if (location != null) {
            return listingRepository.findByLocationContainingIgnoreCase(location);
        } else if (maxPrice != null) {
            return listingRepository.findByPriceLessThanEqual(maxPrice);
        }
        return listingRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Listing> getOne(@PathVariable Long id) {
        return listingRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/favorites")
    public ResponseEntity<?> saveFavorite(@RequestParam Long userId, @RequestParam Long listingId) {
        if (savedPropertyRepository.findByUserIdAndListingId(userId, listingId).isPresent()) {
            return ResponseEntity.ok(Map.of("message", "Already saved"));
        }
        SavedProperty sp = new SavedProperty();
        sp.setUserId(userId);
        sp.setListingId(listingId);
        savedPropertyRepository.save(sp);
        return ResponseEntity.ok(Map.of("message", "Saved"));
    }

    @GetMapping("/favorites/{userId}")
    public List<Map<String, Object>> getFavorites(@PathVariable Long userId) {
        List<SavedProperty> saved = savedPropertyRepository.findByUserId(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (SavedProperty sp : saved) {
            listingRepository.findById(sp.getListingId()).ifPresent(listing -> {
                Map<String, Object> entry = new LinkedHashMap<>();
                entry.put("savedId", sp.getId());
                entry.put("listing", listing);
                result.add(entry);
            });
        }
        return result;
    }

    @DeleteMapping("/favorites")
    @Transactional
    public ResponseEntity<?> removeFavorite(@RequestParam Long userId, @RequestParam Long listingId) {
        savedPropertyRepository.deleteByUserIdAndListingId(userId, listingId);
        return ResponseEntity.ok(Map.of("message", "Removed"));
    }
}
