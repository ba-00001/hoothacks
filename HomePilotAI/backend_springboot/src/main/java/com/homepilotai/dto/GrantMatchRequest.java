package com.homepilotai.dto;

import com.homepilotai.models.RentOrBuyPreference;

public record GrantMatchRequest(
        String incomeRange,
        Integer householdSize,
        Integer creditEstimate,
        String preferredLocation,
        RentOrBuyPreference rentOrBuy
) {
}
