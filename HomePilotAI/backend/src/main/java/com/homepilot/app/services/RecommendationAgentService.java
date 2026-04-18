package com.homepilot.app.services;

import com.homepilot.app.models.Listing;
import com.homepilot.app.models.User;
import com.homepilot.app.repositories.ListingRepository;
import com.homepilot.app.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecommendationAgentService {

    @Autowired private UserRepository userRepository;
    @Autowired private ListingRepository listingRepository;
    @Autowired private AgentClientService agentClient;

    public Map<String, Object> recommend(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String preference = user.getRentOrBuy() != null ? user.getRentOrBuy() : "rent";
        List<Listing> listings = listingRepository.findByType(preference);

        List<Map<String, Object>> ranked = listings.stream()
                .limit(5)
                .map(l -> {
                    Map<String, Object> entry = new LinkedHashMap<>();
                    entry.put("listingId", l.getId());
                    entry.put("title", l.getTitle());
                    entry.put("price", l.getPrice());
                    entry.put("location", l.getLocation());
                    entry.put("bedrooms", l.getBedrooms());
                    entry.put("bathrooms", l.getBathrooms());
                    entry.put("score", Math.round(Math.random() * 30 + 70) / 100.0);
                    return entry;
                })
                .sorted((a, b) -> Double.compare((Double)b.get("score"), (Double)a.get("score")))
                .collect(Collectors.toList());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("userId", userId);
        result.put("preference", preference);
        result.put("recommendations", ranked);

        if (agentClient.isAvailable()) {
            String agentResponse = agentClient.askWithProfile(user, "recommendations");
            if (agentResponse != null) {
                result.put("agentInsight", agentResponse);
                result.put("source", "Google ADK Agent + local listings");
                return result;
            }
        }

        result.put("source", "local-calculator");
        return result;
    }
}
