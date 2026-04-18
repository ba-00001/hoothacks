package com.homepilot.app.services;

import com.homepilot.app.dto.AuthResponse;
import com.homepilot.app.models.User;
import com.homepilot.app.repositories.UserRepository;
import com.homepilot.app.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import java.util.Collections;
import java.util.Map;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired private UserRepository userRepository;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private PasswordEncoder passwordEncoder;

    @Value("${google.client-id:}")
    private String googleClientId;

    public AuthResponse register(String email, String password) {
        if (userRepository.findByEmail(email).isPresent()) {
            throw new RuntimeException("Email already in use");
        }
        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        userRepository.save(user);
        String token = jwtUtil.generateToken(email, user.getId());
        return new AuthResponse(token, "Signup successful", user.getId());
    }

    public AuthResponse login(String email, String password) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (user.getPassword() == null || !passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }
        String token = jwtUtil.generateToken(email, user.getId());
        return new AuthResponse(token, "Login successful", user.getId());
    }

    public AuthResponse googleAuth(String googleToken) {
        String email = null;
        String name = null;

        // 1. Try as ID token first
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();
            GoogleIdToken idToken = verifier.verify(googleToken);
            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();
                email = payload.getEmail();
                name = (String) payload.get("name");
            }
        } catch (Exception e) {
            // Not a valid ID token — that's fine, try as access token
        }

        // 2. If ID token didn't work, treat it as an access token
        if (email == null) {
            try {
                RestTemplate rest = new RestTemplate();
                @SuppressWarnings("unchecked")
                Map<String, Object> userInfo = rest.getForObject(
                    "https://www.googleapis.com/oauth2/v3/userinfo?access_token=" + googleToken,
                    Map.class
                );
                if (userInfo != null && userInfo.get("email") != null) {
                    email = (String) userInfo.get("email");
                    name = (String) userInfo.get("name");
                } else {
                    throw new RuntimeException("Could not get email from Google");
                }
            } catch (Exception e) {
                throw new RuntimeException("Invalid Google token: " + e.getMessage());
            }
        }

        // 3. Find or create user
        final String finalEmail = email;
        final String finalName = name;
        Optional<User> existing = userRepository.findByEmail(finalEmail);
        User user;
        if (existing.isPresent()) {
            user = existing.get();
        } else {
            user = new User();
            user.setEmail(finalEmail);
            user.setName(finalName);
            userRepository.save(user);
        }

        String token = jwtUtil.generateToken(finalEmail, user.getId());
        return new AuthResponse(token, "Google auth successful", user.getId());
    }
}
