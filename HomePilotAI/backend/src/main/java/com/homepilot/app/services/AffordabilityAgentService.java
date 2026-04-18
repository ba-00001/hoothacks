package com.homepilot.app.services;

import com.homepilot.app.models.User;
import com.homepilot.app.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class AffordabilityAgentService {

    @Autowired private UserRepository userRepository;
    @Autowired private AgentClientService agentClient;

    public Map<String, Object> calculateAffordability(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Try real agent first
        if (agentClient.isAvailable()) {
            String agentResponse = agentClient.askWithProfile(user, "affordability");
            if (agentResponse != null) {
                Map<String, Object> result = new LinkedHashMap<>();
                result.put("userId", userId);
                result.put("summary", agentResponse);
                result.put("source", "Google ADK Agent");
                return result;
            }
        }

        // Fallback to local calculation
        int estimatedIncome = estimateIncomeFromRange(user.getIncomeRange());
        int householdSize = user.getHouseholdSize() != null ? user.getHouseholdSize() : 1;
        double monthlyIncome = estimatedIncome / 12.0;
        double maxRent = monthlyIncome * 0.30;
        double minRent = monthlyIncome * 0.20;
        double maxPurchase = estimatedIncome * 4.0;
        double dti = (maxRent / monthlyIncome) * 100;

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("userId", userId);
        result.put("estimatedAnnualIncome", estimatedIncome);
        result.put("householdSize", householdSize);
        result.put("recommendedRentMin", Math.round(minRent));
        result.put("recommendedRentMax", Math.round(maxRent));
        result.put("recommendedPurchaseMax", Math.round(maxPurchase));
        result.put("estimatedDTI", Math.round(dti) + "%");
        result.put("summary", String.format(
                "Based on your income and household size, your recommended monthly rent range is $%,d–$%,d. Max home purchase: ~$%,dk.",
                Math.round(minRent), Math.round(maxRent), Math.round(maxPurchase / 1000)));
        result.put("source", "local-calculator");
        return result;
    }

    private int estimateIncomeFromRange(String range) {
        if (range == null) return 50000;
        return switch (range.toLowerCase()) {
            case "under_25k", "0-25k" -> 20000;
            case "25k-50k" -> 37500;
            case "50k-75k" -> 62500;
            case "75k-100k" -> 87500;
            case "100k-150k" -> 125000;
            case "150k+" -> 175000;
            default -> 50000;
        };
    }
}
