package com.homepilot.app.repositories;

import com.homepilot.app.models.MortgageEstimate;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface MortgageEstimateRepository extends JpaRepository<MortgageEstimate, Long> {
    Optional<MortgageEstimate> findByUserId(Long userId);
}
