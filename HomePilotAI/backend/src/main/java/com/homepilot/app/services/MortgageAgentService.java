package com.homepilot.app.services;

import com.homepilot.app.models.User;
import com.homepilot.app.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class MortgageAgentService {

    @Autowired private UserRepository userRepository;
    @Autowired private AgentClientService agentClient;

    public Map<String, Object> estimate(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        int income = estimateIncome(user.getIncomeRange());
        int credit = user.getCreditEstimate() != null ? user.getCreditEstimate() : 650;
        double maxPurchase = income * 4.0;
        double downPayment = maxPurchase * 0.10;
        double loanAmount = maxPurchase - downPayment;
        double monthlyRate = 0.065 / 12;
        int months = 360;
        double monthlyPayment = (loanAmount * monthlyRate) / (1 - Math.pow(1 + monthlyRate, -months));
        double readiness = credit >= 700 ? 0.85 : credit >= 650 ? 0.65 : 0.40;

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("userId", userId);
        result.put("creditEstimate", credit);
        result.put("recommendedPurchasePrice", Math.round(maxPurchase));
        result.put("estimatedDownPayment", Math.round(downPayment));
        result.put("estimatedMonthlyPayment", Math.round(monthlyPayment));
        result.put("interestRateUsed", "6.5%");
        result.put("loanTermYears", 30);
        result.put("readinessScore", readiness);

        if (agentClient.isAvailable()) {
            String agentResponse = agentClient.askWithProfile(user, "mortgage");
            if (agentResponse != null) {
                result.put("agentInsight", agentResponse);
                result.put("source", "Google ADK Agent + local calculator");
                return result;
            }
        }

        result.put("source", "local-calculator");
        return result;
    }

    private int estimateIncome(String range) {
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
