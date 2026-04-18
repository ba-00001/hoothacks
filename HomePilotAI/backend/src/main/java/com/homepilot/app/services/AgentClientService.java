package com.homepilot.app.services;

import com.homepilot.app.models.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class AgentClientService {

    @Value("${agent.api.url:}")
    private String agentApiUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    public boolean isAvailable() {
        return agentApiUrl != null && !agentApiUrl.isBlank();
    }

    /**
     * Sends a question to the Google ADK orchestrator agent and returns
     * the final text response. The agent internally routes to sub-agents.
     */
    public String ask(String question, String userId, String sessionId) {
        if (!isAvailable()) return null;

        try {
            Map<String, String> body = new LinkedHashMap<>();
            body.put("question", question);
            body.put("user_id", userId);
            body.put("session_id", sessionId);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, String>> request = new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(
                    agentApiUrl + "/agent/respond",
                    request,
                    String.class
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return extractFinalResponse(response.getBody());
            }
        } catch (Exception e) {
            System.err.println("Agent API call failed: " + e.getMessage());
        }
        return null;
    }

    /**
     * Build a structured prompt for a specific agent task using the user's profile.
     */
    public String askWithProfile(User user, String taskType) {
        String prompt = buildPromptFromProfile(user, taskType);
        String sessionId = "session-" + user.getId() + "-" + taskType;
        return ask(prompt, "user-" + user.getId(), sessionId);
    }

    private String buildPromptFromProfile(User user, String taskType) {
        StringBuilder sb = new StringBuilder();
        sb.append("User profile: ");
        if (user.getName() != null) sb.append("Name: ").append(user.getName()).append(". ");
        if (user.getIncomeRange() != null) sb.append("Income range: ").append(user.getIncomeRange()).append(". ");
        if (user.getEmploymentStatus() != null) sb.append("Employment: ").append(user.getEmploymentStatus()).append(". ");
        if (user.getHouseholdSize() != null) sb.append("Household size: ").append(user.getHouseholdSize()).append(". ");
        if (user.getCreditEstimate() != null) sb.append("Credit estimate: ").append(user.getCreditEstimate()).append(". ");
        if (user.getPreferredLocation() != null) sb.append("Preferred location: ").append(user.getPreferredLocation()).append(". ");
        if (user.getRentOrBuy() != null) sb.append("Looking to: ").append(user.getRentOrBuy()).append(". ");

        switch (taskType) {
            case "affordability" -> sb.append("\n\nWhat is my recommended housing budget? Include rent range and purchase range.");
            case "grants" -> sb.append("\n\nWhat housing grants or assistance programs do I qualify for? Include specific programs and amounts.");
            case "recommendations" -> sb.append("\n\nRecommend the best housing listings for me based on my profile. Rank them by fit score.");
            case "mortgage" -> sb.append("\n\nGive me a mortgage estimate. Include monthly payment, readiness score, and whether a bank would approve me.");
        }
        return sb.toString();
    }

    /**
     * Parse the streamed NDJSON response from the ADK agent.
     * Extracts text from the last agent response event.
     */
    private String extractFinalResponse(String rawResponse) {
        String[] lines = rawResponse.split("\n");
        StringBuilder result = new StringBuilder();
        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty()) continue;
            // The ADK streams JSON events; extract text content
            if (line.contains("\"text\"")) {
                int start = line.indexOf("\"text\"");
                if (start >= 0) {
                    // Simple extraction — find the value after "text":"
                    int valueStart = line.indexOf(":", start) + 1;
                    String rest = line.substring(valueStart).trim();
                    if (rest.startsWith("\"")) {
                        int end = rest.indexOf("\"", 1);
                        if (end > 0) {
                            result.append(rest, 1, end);
                        }
                    }
                }
            }
        }
        return result.length() > 0 ? result.toString() : rawResponse;
    }
}
