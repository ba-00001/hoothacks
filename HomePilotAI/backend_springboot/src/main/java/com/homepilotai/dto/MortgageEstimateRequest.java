package com.homepilotai.dto;

import java.math.BigDecimal;

public record MortgageEstimateRequest(
        String incomeRange,
        Integer creditEstimate,
        BigDecimal downPayment
) {
}
