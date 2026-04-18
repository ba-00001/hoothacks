package com.homepilotai.services;

import com.homepilotai.agents.RecommendationAgentConnector;
import com.homepilotai.dto.RecommendationRequest;
import com.homepilotai.dto.RecommendationResponse;
import com.homepilotai.models.AppUser;
import com.homepilotai.models.Recommendation;
import com.homepilotai.repositories.RecommendationRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RecommendationAgentService {

    private final ListingService listingService;
    private final RecommendationAgentConnector recommendationAgentConnector;
    private final RecommendationRepository recommendationRepository;

    @Transactional
    public RecommendationResponse recommend(AppUser user, RecommendationRequest request) {
        RecommendationResponse recommendationResponse = recommendationAgentConnector.recommend(user, request);

        recommendationRepository.deleteByUserId(user.getId());

        recommendationRepository.saveAll(recommendationResponse.recommendations().stream()
                .map(result -> Recommendation.builder()
                        .user(user)
                        .listing(listingService.getListingEntity(result.listingId()))
                        .score(result.score())
                        .build())
                .toList());

        return recommendationResponse;
    }
}
