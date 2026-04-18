package com.homepilotai.services;

import com.homepilotai.dto.AffordabilityRequest;
import com.homepilotai.dto.AffordabilityResponse;
import com.homepilotai.models.AppUser;
import java.math.BigDecimal;
import java.math.RoundingMode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AffordabilityAgentService {

    private final FinancialProfileSupportService profileSupportService;

    public AffordabilityResponse estimate(AppUser user, AffordabilityRequest request) {
        String incomeRange = profileSupportService.resolveIncomeRange(request == null ? null : request.incomeRange(), user);
        String employmentStatus = profileSupportService.resolveEmploymentStatus(request == null ? null : request.employmentStatus(), user);
        int householdSize = profileSupportService.resolveHouseholdSize(request == null ? null : request.householdSize(), user);
        int creditEstimate = profileSupportService.resolveCreditEstimate(request == null ? null : request.creditEstimate(), user);

        BigDecimal monthlyIncome = profileSupportService.estimateMonthlyIncome(incomeRange);
        BigDecimal recommendedBudget = profileSupportService.budgetFromMonthlyIncome(monthlyIncome);
        BigDecimal recommendedRentMin = recommendedBudget.multiply(BigDecimal.valueOf(0.85)).setScale(0, RoundingMode.HALF_UP);
        BigDecimal recommendedRentMax = recommendedBudget.multiply(BigDecimal.valueOf(1.1)).setScale(0, RoundingMode.HALF_UP);

        double purchaseMultiplier = 170 * profileSupportService.creditMultiplier(creditEstimate);
        BigDecimal recommendedPurchaseMin = recommendedBudget.multiply(BigDecimal.valueOf(purchaseMultiplier * 0.88)).setScale(0, RoundingMode.HALF_UP);
        BigDecimal recommendedPurchaseMax = recommendedBudget.multiply(BigDecimal.valueOf(purchaseMultiplier * 1.05)).setScale(0, RoundingMode.HALF_UP);

        double debtRatio = profileSupportService.estimateDebtRatio(employmentStatus, householdSize);
        String message = String.format(
                "Based on your income and household size your recommended monthly rent range is $%s-$%s.",
                recommendedRentMin.toPlainString(),
                recommendedRentMax.toPlainString()
        );

        return new AffordabilityResponse(
                message,
                recommendedRentMin,
                recommendedRentMax,
                recommendedPurchaseMin,
                recommendedPurchaseMax,
                debtRatio,
                recommendedBudget.setScale(0, RoundingMode.HALF_UP)
        );
    }
}
