package com.homepilot.app.controllers;

import com.homepilot.app.dto.AuthRequest;
import com.homepilot.app.dto.AuthResponse;
import com.homepilot.app.dto.ProfileRequest;
import com.homepilot.app.models.User;
import com.homepilot.app.repositories.UserRepository;
import com.homepilot.app.services.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired private AuthService authService;
    @Autowired private UserRepository userRepository;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody AuthRequest request) {
        try {
            AuthResponse resp = authService.register(request.email, request.password);
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        try {
            AuthResponse resp = authService.login(request.email, request.password);
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            return ResponseEntity.status(401).body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/google")
    public ResponseEntity<?> googleLogin(@RequestBody AuthRequest request) {
        try {
            AuthResponse resp = authService.googleAuth(request.googleIdToken);
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/profile/{userId}")
    public ResponseEntity<?> getProfile(@PathVariable Long userId) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) return ResponseEntity.notFound().build();
        // Don't return password
        user.setPassword(null);
        return ResponseEntity.ok(user);
    }

    @PutMapping("/profile/{userId}")
    public ResponseEntity<?> updateProfile(@PathVariable Long userId, @RequestBody ProfileRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (req.name != null) user.setName(req.name);
        if (req.incomeRange != null) user.setIncomeRange(req.incomeRange);
        if (req.employmentStatus != null) user.setEmploymentStatus(req.employmentStatus);
        if (req.householdSize != null) user.setHouseholdSize(req.householdSize);
        if (req.creditEstimate != null) user.setCreditEstimate(req.creditEstimate);
        if (req.preferredLocation != null) user.setPreferredLocation(req.preferredLocation);
        if (req.rentOrBuy != null) user.setRentOrBuy(req.rentOrBuy);
        userRepository.save(user);
        user.setPassword(null);
        return ResponseEntity.ok(user);
    }
}
