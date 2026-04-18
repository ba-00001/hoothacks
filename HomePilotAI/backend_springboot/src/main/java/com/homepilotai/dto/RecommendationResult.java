package com.homepilotai.dto;

import com.homepilotai.models.RentOrBuyPreference;
import java.math.BigDecimal;

public record RecommendationResult(
        Long listingId,
        String title,
        BigDecimal price,
        String location,
        Integer bedrooms,
        Integer bathrooms,
        RentOrBuyPreference rentOrBuy,
        double score,
        String fitSummary
) {
}
