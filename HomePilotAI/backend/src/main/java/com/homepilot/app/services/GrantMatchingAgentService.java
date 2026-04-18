package com.homepilot.app.services;

import com.homepilot.app.models.User;
import com.homepilot.app.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class GrantMatchingAgentService {

    @Autowired private UserRepository userRepository;
    @Autowired private AgentClientService agentClient;

    public Map<String, Object> matchGrants(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (agentClient.isAvailable()) {
            String agentResponse = agentClient.askWithProfile(user, "grants");
            if (agentResponse != null) {
                Map<String, Object> result = new LinkedHashMap<>();
                result.put("userId", userId);
                result.put("summary", agentResponse);
                result.put("source", "Google ADK Agent");
                // Still return structured data for the UI cards
                result.put("matchedGrants", buildDefaultGrants());
                result.put("totalPotentialAid", 30000);
                return result;
            }
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("userId", userId);
        result.put("matchedGrants", buildDefaultGrants());
        result.put("totalPotentialAid", 30000);
        result.put("source", "local-calculator");
        return result;
    }

    private List<Map<String, Object>> buildDefaultGrants() {
        List<Map<String, Object>> grants = new ArrayList<>();
        grants.add(Map.of("programName", "First-Time Home Buyer Assistance", "coverageAmount", 15000, "eligibility", "First-time buyer, income < $75k", "matchScore", 0.92));
        grants.add(Map.of("programName", "State Housing Down Payment Grant", "coverageAmount", 10000, "eligibility", "State resident, household size >= 2", "matchScore", 0.85));
        grants.add(Map.of("programName", "Student Housing Support Program", "coverageAmount", 5000, "eligibility", "Currently enrolled student", "matchScore", 0.70));
        return grants;
    }
}
