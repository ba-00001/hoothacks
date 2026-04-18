package com.homepilotai.controllers;

import com.homepilotai.dto.AffordabilityRequest;
import com.homepilotai.dto.AffordabilityResponse;
import com.homepilotai.dto.GrantMatchRequest;
import com.homepilotai.dto.GrantMatchResponse;
import com.homepilotai.dto.MortgageEstimateRequest;
import com.homepilotai.dto.MortgageEstimateResponse;
import com.homepilotai.dto.RecommendationRequest;
import com.homepilotai.dto.RecommendationResponse;
import com.homepilotai.services.AffordabilityAgentService;
import com.homepilotai.services.GrantMatchingAgentService;
import com.homepilotai.services.MortgageAgentService;
import com.homepilotai.services.RecommendationAgentService;
import com.homepilotai.services.UserProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
public class AiController {

    private final AffordabilityAgentService affordabilityAgentService;
    private final GrantMatchingAgentService grantMatchingAgentService;
    private final RecommendationAgentService recommendationAgentService;
    private final MortgageAgentService mortgageAgentService;
    private final UserProfileService userProfileService;

    @PostMapping("/affordability")
    public AffordabilityResponse affordability(
            Authentication authentication,
            @RequestBody(required = false) AffordabilityRequest request
    ) {
        return affordabilityAgentService.estimate(userProfileService.getCurrentUser(authentication), request);
    }

    @PostMapping("/grants")
    public GrantMatchResponse grants(
            Authentication authentication,
            @RequestBody(required = false) GrantMatchRequest request
    ) {
        return grantMatchingAgentService.match(userProfileService.getCurrentUser(authentication), request);
    }

    @PostMapping("/recommendations")
    public RecommendationResponse recommendations(
            Authentication authentication,
            @RequestBody(required = false) RecommendationRequest request
    ) {
        return recommendationAgentService.recommend(userProfileService.getCurrentUser(authentication), request);
    }

    @PostMapping("/mortgage-estimate")
    public MortgageEstimateResponse mortgageEstimate(
            Authentication authentication,
            @RequestBody(required = false) MortgageEstimateRequest request
    ) {
        return mortgageAgentService.estimate(userProfileService.getCurrentUser(authentication), request);
    }
}
