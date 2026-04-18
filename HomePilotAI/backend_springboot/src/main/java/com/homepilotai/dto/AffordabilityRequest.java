package com.homepilotai.dto;

import com.homepilotai.models.RentOrBuyPreference;

public record AffordabilityRequest(
        String incomeRange,
        String employmentStatus,
        Integer householdSize,
        Integer creditEstimate,
        RentOrBuyPreference rentOrBuy
) {
}
