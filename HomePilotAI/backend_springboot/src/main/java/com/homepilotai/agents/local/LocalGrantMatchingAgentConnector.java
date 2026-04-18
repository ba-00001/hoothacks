package com.homepilotai.agents.local;

import com.homepilotai.agents.GrantMatchingAgentConnector;
import com.homepilotai.dto.GrantMatchRequest;
import com.homepilotai.dto.GrantMatchResponse;
import com.homepilotai.dto.GrantMatchResult;
import com.homepilotai.models.AppUser;
import com.homepilotai.models.GrantProgram;
import com.homepilotai.models.RentOrBuyPreference;
import com.homepilotai.repositories.GrantProgramRepository;
import com.homepilotai.services.FinancialProfileSupportService;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LocalGrantMatchingAgentConnector implements GrantMatchingAgentConnector {

    private final GrantProgramRepository grantProgramRepository;
    private final FinancialProfileSupportService profileSupportService;

    @Override
    public GrantMatchResponse match(AppUser user, GrantMatchRequest request) {
        String incomeRange = profileSupportService.resolveIncomeRange(request == null ? null : request.incomeRange(), user);
        int householdSize = profileSupportService.resolveHouseholdSize(request == null ? null : request.householdSize(), user);
        int creditEstimate = profileSupportService.resolveCreditEstimate(request == null ? null : request.creditEstimate(), user);
        String preferredLocation = profileSupportService.resolvePreferredLocation(request == null ? null : request.preferredLocation(), user);
        RentOrBuyPreference preference = profileSupportService.resolvePreference(request == null ? null : request.rentOrBuy(), user);
        BigDecimal annualIncome = profileSupportService.estimateAnnualIncome(incomeRange);

        List<GrantMatchResult> matches = grantProgramRepository.findAll().stream()
                .map(program -> scoreProgram(program, annualIncome.intValue(), householdSize, creditEstimate, preferredLocation, preference))
                .filter(result -> result.eligibilityScore() >= 50)
                .sorted(Comparator.comparingDouble(GrantMatchResult::eligibilityScore).reversed())
                .toList();

        return new GrantMatchResponse(matches);
    }

    private GrantMatchResult scoreProgram(
            GrantProgram program,
            int annualIncome,
            int householdSize,
            int creditEstimate,
            String preferredLocation,
            RentOrBuyPreference preference
    ) {
        Map<String, String> rules = parseRules(program.getEligibilityRules());
        double score = 55;
        StringBuilder rationale = new StringBuilder();

        String typeRule = rules.getOrDefault("type", "ANY");
        if (!"ANY".equalsIgnoreCase(typeRule) && !preference.name().equalsIgnoreCase(typeRule)) {
            score -= 30;
        } else {
            rationale.append("Matches your ").append(preference.name().toLowerCase(Locale.US)).append(" preference. ");
        }

        int maxIncome = Integer.parseInt(rules.getOrDefault("maxIncome", "999999"));
        if (annualIncome <= maxIncome) {
            score += 20;
            rationale.append("Income appears within the target range. ");
        } else {
            score -= 25;
        }

        int minCredit = Integer.parseInt(rules.getOrDefault("minCredit", "0"));
        if (creditEstimate >= minCredit) {
            score += 10;
        } else {
            score -= 10;
        }

        int householdMin = Integer.parseInt(rules.getOrDefault("householdMin", "1"));
        if (householdSize >= householdMin) {
            score += 8;
        }

        String locationRule = rules.getOrDefault("location", "ANY");
        if ("ANY".equalsIgnoreCase(locationRule) || preferredLocation.toUpperCase(Locale.US).contains(locationRule.toUpperCase(Locale.US))) {
            score += 12;
            rationale.append("Location fit looks strong. ");
        }

        String tag = rules.getOrDefault("tag", "");
        if ("student".equalsIgnoreCase(tag) && annualIncome < 45000) {
            score += 8;
            rationale.append("Income profile may fit student-focused support. ");
        }
        if ("family".equalsIgnoreCase(tag) && householdSize >= 3) {
            score += 8;
            rationale.append("Household size aligns with family assistance criteria. ");
        }

        return new GrantMatchResult(
                program.getId(),
                program.getProgramName(),
                rationale.toString().trim(),
                program.getCoverageAmount(),
                Math.max(0, Math.min(score, 99))
        );
    }

    private Map<String, String> parseRules(String rules) {
        Map<String, String> parsed = new LinkedHashMap<>();
        Arrays.stream(rules.split(";"))
                .map(String::trim)
                .filter(part -> part.contains("="))
                .forEach(part -> {
                    String[] tokens = part.split("=", 2);
                    parsed.put(tokens[0], tokens[1]);
                });
        return parsed;
    }
}
