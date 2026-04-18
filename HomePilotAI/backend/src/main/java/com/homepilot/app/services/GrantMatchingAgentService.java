package com.homepilot.app.services;

import com.homepilot.app.models.User;
import com.homepilot.app.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class GrantMatchingAgentService {

    @Autowired private UserRepository userRepository;

    public Map<String, Object> matchGrants(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // --- PLACEHOLDER: Replace with Google ADK agent call ---
        List<Map<String, Object>> grants = new ArrayList<>();

        Map<String, Object> g1 = new LinkedHashMap<>();
        g1.put("programName", "First-Time Home Buyer Assistance");
        g1.put("coverageAmount", 15000);
        g1.put("eligibility", "First-time buyer, income < $75k");
        g1.put("matchScore", 0.92);
        grants.add(g1);

        Map<String, Object> g2 = new LinkedHashMap<>();
        g2.put("programName", "State Housing Down Payment Grant");
        g2.put("coverageAmount", 10000);
        g2.put("eligibility", "State resident, household size >= 2");
        g2.put("matchScore", 0.85);
        grants.add(g2);

        Map<String, Object> g3 = new LinkedHashMap<>();
        g3.put("programName", "Student Housing Support Program");
        g3.put("coverageAmount", 5000);
        g3.put("eligibility", "Currently enrolled student");
        g3.put("matchScore", 0.70);
        grants.add(g3);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("userId", userId);
        result.put("matchedGrants", grants);
        result.put("totalPotentialAid", 30000);
        result.put("source", "placeholder — awaiting Google ADK agent integration");
        return result;
    }
}
