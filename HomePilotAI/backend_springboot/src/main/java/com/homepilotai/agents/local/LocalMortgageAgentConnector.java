package com.homepilotai.agents.local;

import com.homepilotai.agents.MortgageAgentConnector;
import com.homepilotai.dto.MortgageEstimateRequest;
import com.homepilotai.dto.MortgageEstimateResponse;
import com.homepilotai.models.AppUser;
import com.homepilotai.services.FinancialProfileSupportService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LocalMortgageAgentConnector implements MortgageAgentConnector {

    private final FinancialProfileSupportService profileSupportService;

    @Override
    public MortgageEstimateResponse estimate(AppUser user, MortgageEstimateRequest request) {
        String incomeRange = profileSupportService.resolveIncomeRange(request == null ? null : request.incomeRange(), user);
        int creditEstimate = profileSupportService.resolveCreditEstimate(request == null ? null : request.creditEstimate(), user);
        BigDecimal downPayment = request != null && request.downPayment() != null ? request.downPayment() : BigDecimal.valueOf(10000);

        BigDecimal monthlyIncome = profileSupportService.estimateMonthlyIncome(incomeRange);
        BigDecimal monthlyPayment = monthlyIncome.multiply(BigDecimal.valueOf(0.30)).setScale(0, RoundingMode.HALF_UP);
        BigDecimal borrowingPower = monthlyPayment.multiply(BigDecimal.valueOf(165 * profileSupportService.creditMultiplier(creditEstimate)))
                .setScale(0, RoundingMode.HALF_UP);
        BigDecimal estimatedBudget = borrowingPower.add(downPayment).setScale(0, RoundingMode.HALF_UP);

        int readinessScore = Math.max(45, Math.min(95,
                (int) Math.round((creditEstimate * 0.08) + Math.min(downPayment.doubleValue() / 1500, 20) + 15)));

        return new MortgageEstimateResponse(
                estimatedBudget,
                monthlyPayment,
                readinessScore,
                estimatedBudget.multiply(BigDecimal.valueOf(0.88)).setScale(0, RoundingMode.HALF_UP),
                estimatedBudget.multiply(BigDecimal.valueOf(1.05)).setScale(0, RoundingMode.HALF_UP),
                "Estimated using a conservative 30% housing ratio and a credit-adjusted borrowing range."
        );
    }
}
