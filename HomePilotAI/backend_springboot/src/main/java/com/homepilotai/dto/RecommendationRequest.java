package com.homepilotai.dto;

import com.homepilotai.models.RentOrBuyPreference;
import java.math.BigDecimal;

public record RecommendationRequest(
        String preferredLocation,
        BigDecimal maxPrice,
        RentOrBuyPreference rentOrBuy
) {
}
