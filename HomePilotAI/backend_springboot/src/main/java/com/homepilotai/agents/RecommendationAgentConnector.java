package com.homepilotai.agents;

import com.homepilotai.dto.RecommendationRequest;
import com.homepilotai.dto.RecommendationResponse;
import com.homepilotai.models.AppUser;

public interface RecommendationAgentConnector {

    RecommendationResponse recommend(AppUser user, RecommendationRequest request);
}
