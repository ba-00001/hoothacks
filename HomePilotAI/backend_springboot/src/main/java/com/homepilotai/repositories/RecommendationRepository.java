package com.homepilotai.repositories;

import com.homepilotai.models.Recommendation;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecommendationRepository extends JpaRepository<Recommendation, Long> {

    List<Recommendation> findByUserId(Long userId);

    void deleteByUserId(Long userId);
}
