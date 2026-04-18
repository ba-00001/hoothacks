package com.homepilotai.dto;

import com.homepilotai.models.AppUser;
import com.homepilotai.models.RentOrBuyPreference;
import com.homepilotai.models.UserRole;
import com.homepilotai.models.SubscriptionTier;

public record UserProfileResponse(
        Long id,
        String email,
        String incomeRange,
        String employmentStatus,
        Integer householdSize,
        Integer creditEstimate,
        String preferredLocation,
        RentOrBuyPreference rentOrBuy,
        UserRole role,
        String businessName,
        String phoneNumber,
        SubscriptionTier subscriptionTier
) {

    public static UserProfileResponse from(AppUser user) {
        return new UserProfileResponse(
                user.getId(),
                user.getEmail(),
                user.getIncomeRange(),
                user.getEmploymentStatus(),
                user.getHouseholdSize(),
                user.getCreditEstimate(),
                user.getPreferredLocation(),
                user.getRentOrBuy(),
                user.getRole(),
                user.getBusinessName(),
                user.getPhoneNumber(),
                user.getSubscriptionTier()
        );
    }
}
