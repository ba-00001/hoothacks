package com.homepilotai.services;

import com.homepilotai.models.AppUser;
import com.homepilotai.models.RentOrBuyPreference;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;

@Service
public class FinancialProfileSupportService {

    private static final Pattern NUMBER_PATTERN = Pattern.compile("(\\d[\\d,]*)");

    public String resolveIncomeRange(String requestValue, AppUser user) {
        if (requestValue != null && !requestValue.isBlank()) {
            return requestValue;
        }
        if (user != null && user.getIncomeRange() != null && !user.getIncomeRange().isBlank()) {
            return user.getIncomeRange();
        }
        return "45000-60000";
    }

    public String resolveEmploymentStatus(String requestValue, AppUser user) {
        if (requestValue != null && !requestValue.isBlank()) {
            return requestValue;
        }
        return user != null && user.getEmploymentStatus() != null ? user.getEmploymentStatus() : "Full-time";
    }

    public Integer resolveHouseholdSize(Integer requestValue, AppUser user) {
        if (requestValue != null && requestValue > 0) {
            return requestValue;
        }
        return user != null && user.getHouseholdSize() != null ? user.getHouseholdSize() : 1;
    }

    public Integer resolveCreditEstimate(Integer requestValue, AppUser user) {
        if (requestValue != null && requestValue > 0) {
            return requestValue;
        }
        return user != null && user.getCreditEstimate() != null ? user.getCreditEstimate() : 640;
    }

    public String resolvePreferredLocation(String requestValue, AppUser user) {
        if (requestValue != null && !requestValue.isBlank()) {
            return requestValue;
        }
        return user != null && user.getPreferredLocation() != null ? user.getPreferredLocation() : "Atlanta, GA";
    }

    public RentOrBuyPreference resolvePreference(RentOrBuyPreference requestValue, AppUser user) {
        if (requestValue != null) {
            return requestValue;
        }
        return user != null && user.getRentOrBuy() != null ? user.getRentOrBuy() : RentOrBuyPreference.RENT;
    }

    public BigDecimal estimateAnnualIncome(String incomeRange) {
        Matcher matcher = NUMBER_PATTERN.matcher(incomeRange == null ? "" : incomeRange);
        BigDecimal first = null;
        BigDecimal second = null;

        while (matcher.find()) {
            BigDecimal value = new BigDecimal(matcher.group(1).replace(",", ""));
            if (first == null) {
                first = value;
            } else {
                second = value;
                break;
            }
        }

        if (first == null) {
            return BigDecimal.valueOf(52000);
        }
        if (second == null) {
            return first;
        }
        return first.add(second).divide(BigDecimal.valueOf(2), 2, RoundingMode.HALF_UP);
    }

    public BigDecimal estimateMonthlyIncome(String incomeRange) {
        return estimateAnnualIncome(incomeRange).divide(BigDecimal.valueOf(12), 2, RoundingMode.HALF_UP);
    }

    public double estimateDebtRatio(String employmentStatus, int householdSize) {
        double ratio = 0.18;
        String normalizedStatus = employmentStatus.toLowerCase();
        if (normalizedStatus.contains("part")) {
            ratio += 0.06;
        } else if (normalizedStatus.contains("contract")) {
            ratio += 0.04;
        } else if (normalizedStatus.contains("student")) {
            ratio += 0.03;
        } else if (normalizedStatus.contains("unemployed")) {
            ratio += 0.14;
        }
        ratio += Math.max(0, householdSize - 2) * 0.015;
        return Math.min(ratio, 0.45);
    }

    public BigDecimal budgetFromMonthlyIncome(BigDecimal monthlyIncome) {
        return monthlyIncome.multiply(BigDecimal.valueOf(0.28)).setScale(2, RoundingMode.HALF_UP);
    }

    public double creditMultiplier(int creditEstimate) {
        if (creditEstimate >= 760) {
            return 1.08;
        }
        if (creditEstimate >= 700) {
            return 1.0;
        }
        if (creditEstimate >= 640) {
            return 0.92;
        }
        return 0.84;
    }
}
