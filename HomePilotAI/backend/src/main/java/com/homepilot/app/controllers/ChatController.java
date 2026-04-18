package com.homepilot.app.controllers;

import com.homepilot.app.services.AgentClientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/ai")
public class ChatController {

    @Autowired private AgentClientService agentClient;

    @PostMapping("/chat")
    public ResponseEntity<?> chat(@RequestBody Map<String, String> body) {
        String message = body.get("message");
        String userId = body.getOrDefault("userId", "anonymous");
        String sessionId = body.getOrDefault("sessionId", "chat-" + userId);

        if (message == null || message.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Message is required"));
        }

        if (!agentClient.isAvailable()) {
            return ResponseEntity.ok(Map.of(
                "response", "The AI agent is not connected yet. Please check back soon!",
                "source", "fallback"
            ));
        }

        String response = agentClient.ask(message, userId, sessionId);
        if (response != null) {
            return ResponseEntity.ok(Map.of("response", response, "source", "agent"));
        } else {
            return ResponseEntity.ok(Map.of(
                "response", "I couldn't reach the AI advisor right now. Please try again in a moment.",
                "source", "error"
            ));
        }
    }
}
