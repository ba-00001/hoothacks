package com.homepilotai.dto;

import com.homepilotai.models.AppUser;
import com.homepilotai.models.RentOrBuyPreference;

public record UserProfileResponse(
        Long id,
        String email,
        String incomeRange,
        String employmentStatus,
        Integer householdSize,
        Integer creditEstimate,
        String preferredLocation,
        RentOrBuyPreference rentOrBuy
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
                user.getRentOrBuy()
        );
    }
}
