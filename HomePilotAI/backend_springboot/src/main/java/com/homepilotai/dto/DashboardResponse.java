package com.homepilotai.dto;

import java.util.List;

public record DashboardResponse(
        AffordabilityResponse affordability,
        MortgageEstimateResponse mortgageEstimate,
        GrantMatchResponse grants,
        List<RecommendationResult> topListings
) {
}
