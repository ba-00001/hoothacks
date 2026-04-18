package com.homepilotai.services;

import com.homepilotai.dto.AuthResponse;
import com.homepilotai.dto.LandlordSignupRequest;
import com.homepilotai.dto.LoginRequest;
import com.homepilotai.dto.SignupRequest;
import com.homepilotai.dto.UserProfileResponse;
import com.homepilotai.models.AppUser;
import com.homepilotai.repositories.AppUserRepository;
import com.homepilotai.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final com.homepilotai.security.CustomUserDetailsService customUserDetailsService;
    private final JwtService jwtService;
    private final RestTemplate restTemplate;

    public AuthResponse signup(SignupRequest request) {
        if (appUserRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("An account with that email already exists");
        }

        AppUser user = appUserRepository.save(AppUser.builder()
                .email(request.email().toLowerCase().trim())
                .password(passwordEncoder.encode(request.password()))
                .build());

        UserDetails userDetails = customUserDetailsService.loadUserByUsername(user.getEmail());
        String token = jwtService.generateToken(userDetails);
        return new AuthResponse(token, UserProfileResponse.from(user));
    }

    @SuppressWarnings("unchecked")
    public AuthResponse googleLogin(String idToken) {
        String url = "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken;
        Map<String, Object> tokenInfo;
        try {
            tokenInfo = restTemplate.getForObject(url, Map.class);
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid or expired Google token");
        }

        if (tokenInfo == null || !tokenInfo.containsKey("email")) {
            throw new IllegalArgumentException("Google token did not contain an email");
        }

        String email = ((String) tokenInfo.get("email")).toLowerCase().trim();

        AppUser user = appUserRepository.findByEmail(email).orElseGet(() ->
                appUserRepository.save(AppUser.builder()
                        .email(email)
                        .password(passwordEncoder.encode(UUID.randomUUID().toString()))
                        .build())
        );

        UserDetails userDetails = customUserDetailsService.loadUserByUsername(user.getEmail());
        return new AuthResponse(jwtService.generateToken(userDetails), UserProfileResponse.from(user));
    }

    public AuthResponse landlordSignup(LandlordSignupRequest request) {
        if (appUserRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("An account with that email already exists");
        }
        AppUser user = appUserRepository.save(AppUser.builder()
                .email(request.email().toLowerCase().trim())
                .password(passwordEncoder.encode(request.password()))
                .role(request.role())
                .businessName(request.businessName())
                .phoneNumber(request.phoneNumber())
                .subscriptionTier(request.subscriptionTier())
                .build());
        UserDetails userDetails = customUserDetailsService.loadUserByUsername(user.getEmail());
        return new AuthResponse(jwtService.generateToken(userDetails), UserProfileResponse.from(user));
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(request.email(), request.password()));
        UserDetails userDetails = customUserDetailsService.loadUserByUsername(request.email());
        AppUser user = appUserRepository.findByEmail(request.email())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        return new AuthResponse(jwtService.generateToken(userDetails), UserProfileResponse.from(user));
    }
}
