package com.homepilotai.dto;

import java.math.BigDecimal;

public record GrantMatchResult(
        Long programId,
        String programName,
        String rationale,
        BigDecimal coverageAmount,
        double eligibilityScore
) {
}
