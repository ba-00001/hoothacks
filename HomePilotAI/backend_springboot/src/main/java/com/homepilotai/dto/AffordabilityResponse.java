package com.homepilotai.dto;

import java.math.BigDecimal;

public record AffordabilityResponse(
        String message,
        BigDecimal recommendedRentMin,
        BigDecimal recommendedRentMax,
        BigDecimal recommendedPurchaseMin,
        BigDecimal recommendedPurchaseMax,
        double estimatedDebtToIncomeRatio,
        BigDecimal recommendedHousingBudget
) {
}
