package com.homepilotai.dto;

public record AuthResponse(
        String token,
        UserProfileResponse user
) {
}
