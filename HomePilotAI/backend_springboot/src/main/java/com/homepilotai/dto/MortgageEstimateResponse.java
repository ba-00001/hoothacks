package com.homepilotai.dto;

import java.math.BigDecimal;

public record MortgageEstimateResponse(
        BigDecimal estimatedBudget,
        BigDecimal monthlyPayment,
        int readinessScore,
        BigDecimal recommendedPurchaseMin,
        BigDecimal recommendedPurchaseMax,
        String summary
) {
}
