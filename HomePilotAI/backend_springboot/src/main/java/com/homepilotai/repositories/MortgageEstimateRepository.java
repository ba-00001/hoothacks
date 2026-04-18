package com.homepilotai.repositories;

import com.homepilotai.models.MortgageEstimate;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MortgageEstimateRepository extends JpaRepository<MortgageEstimate, Long> {

    Optional<MortgageEstimate> findTopByUserIdOrderByIdDesc(Long userId);
}
