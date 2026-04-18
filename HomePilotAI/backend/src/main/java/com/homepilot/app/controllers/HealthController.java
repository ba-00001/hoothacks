package com.homepilot.app.controllers;

import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
public class HealthController {

    @GetMapping("/")
    public Map<String, String> health() {
        return Map.of("status", "running", "app", "HomePilot AI Backend");
    }
}
