package com.homepilotai.services;

import com.homepilotai.dto.AffordabilityRequest;
import com.homepilotai.dto.DashboardResponse;
import com.homepilotai.dto.GrantMatchRequest;
import com.homepilotai.dto.MortgageEstimateRequest;
import com.homepilotai.dto.RecommendationRequest;
import com.homepilotai.models.AppUser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final AffordabilityAgentService affordabilityAgentService;
    private final GrantMatchingAgentService grantMatchingAgentService;
    private final RecommendationAgentService recommendationAgentService;
    private final MortgageAgentService mortgageAgentService;

    public DashboardResponse buildDashboard(AppUser user) {
        return new DashboardResponse(
                affordabilityAgentService.estimate(user, new AffordabilityRequest(null, null, null, null, null)),
                mortgageAgentService.estimate(user, new MortgageEstimateRequest(null, null, null)),
                grantMatchingAgentService.match(user, new GrantMatchRequest(null, null, null, null, null)),
                recommendationAgentService.recommend(user, new RecommendationRequest(null, null, null)).recommendations()
        );
    }
}
