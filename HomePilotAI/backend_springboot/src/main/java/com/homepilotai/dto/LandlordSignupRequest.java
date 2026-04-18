package com.homepilotai.dto;

import com.homepilotai.models.SubscriptionTier;
import com.homepilotai.models.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record LandlordSignupRequest(
        @Email @NotBlank String email,
        @NotBlank @Size(min = 6) String password,
        @NotBlank String businessName,
        String phoneNumber,
        @NotNull UserRole role,           // LANDLORD or AGENT
        @NotNull SubscriptionTier subscriptionTier
) {
}
