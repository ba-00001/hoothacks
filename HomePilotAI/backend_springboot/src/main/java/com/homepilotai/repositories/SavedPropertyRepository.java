package com.homepilotai.repositories;

import com.homepilotai.models.SavedProperty;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SavedPropertyRepository extends JpaRepository<SavedProperty, Long> {

    List<SavedProperty> findByUserId(Long userId);

    Optional<SavedProperty> findByUserIdAndListingId(Long userId, Long listingId);
}
