package com.homepilotai.dto;

import com.homepilotai.models.RentOrBuyPreference;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ProfileSetupRequest(
        @NotBlank String incomeRange,
        @NotBlank String employmentStatus,
        @NotNull @Min(1) Integer householdSize,
        Integer creditEstimate,
        @NotBlank String preferredLocation,
        @NotNull RentOrBuyPreference rentOrBuy
) {
}
