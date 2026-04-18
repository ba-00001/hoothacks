package com.homepilotai.controllers;

import com.homepilotai.dto.ProfileSetupRequest;
import com.homepilotai.dto.UserProfileResponse;
import com.homepilotai.services.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final UserProfileService userProfileService;

    @GetMapping
    public UserProfileResponse getProfile(Authentication authentication) {
        return userProfileService.getCurrentUserProfile(authentication);
    }

    @PutMapping
    public UserProfileResponse updateProfile(
            Authentication authentication,
            @Valid @RequestBody ProfileSetupRequest request
    ) {
        return userProfileService.updateProfile(authentication, request);
    }
}
