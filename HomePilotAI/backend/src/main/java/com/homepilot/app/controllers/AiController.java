package com.homepilot.app.controllers;

import com.homepilot.app.services.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/ai")
public class AiController {

    @Autowired private AffordabilityAgentService affordabilityAgent;
    @Autowired private GrantMatchingAgentService grantMatchingAgent;
    @Autowired private RecommendationAgentService recommendationAgent;
    @Autowired private MortgageAgentService mortgageAgent;

    @PostMapping("/affordability")
    public ResponseEntity<?> getAffordability(@RequestParam Long userId) {
        try {
            return ResponseEntity.ok(affordabilityAgent.calculateAffordability(userId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/grants")
    public ResponseEntity<?> getGrants(@RequestParam Long userId) {
        try {
            return ResponseEntity.ok(grantMatchingAgent.matchGrants(userId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/recommendations")
    public ResponseEntity<?> getRecommendations(@RequestParam Long userId) {
        try {
            return ResponseEntity.ok(recommendationAgent.recommend(userId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/mortgage-estimate")
    public ResponseEntity<?> getMortgageEstimate(@RequestParam Long userId) {
        try {
            return ResponseEntity.ok(mortgageAgent.estimate(userId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
