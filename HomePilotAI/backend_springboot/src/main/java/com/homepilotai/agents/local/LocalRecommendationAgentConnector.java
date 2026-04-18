package com.homepilotai.agents.local;

import com.homepilotai.agents.AffordabilityAgentConnector;
import com.homepilotai.agents.GrantMatchingAgentConnector;
import com.homepilotai.agents.RecommendationAgentConnector;
import com.homepilotai.dto.AffordabilityRequest;
import com.homepilotai.dto.GrantMatchRequest;
import com.homepilotai.dto.GrantMatchResponse;
import com.homepilotai.dto.RecommendationRequest;
import com.homepilotai.dto.RecommendationResponse;
import com.homepilotai.dto.RecommendationResult;
import com.homepilotai.models.AppUser;
import com.homepilotai.models.Listing;
import com.homepilotai.models.RentOrBuyPreference;
import com.homepilotai.services.FinancialProfileSupportService;
import com.homepilotai.services.ListingService;
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LocalRecommendationAgentConnector implements RecommendationAgentConnector {

    private final ListingService listingService;
    private final AffordabilityAgentConnector affordabilityAgentConnector;
    private final GrantMatchingAgentConnector grantMatchingAgentConnector;
    private final FinancialProfileSupportService profileSupportService;

    @Override
    public RecommendationResponse recommend(AppUser user, RecommendationRequest request) {
        var affordability = affordabilityAgentConnector.estimate(user, new AffordabilityRequest(null, null, null, null, null));
        GrantMatchResponse grantMatches = grantMatchingAgentConnector.match(user, new GrantMatchRequest(null, null, null, null, null));
        String preferredLocation = profileSupportService.resolvePreferredLocation(request == null ? null : request.preferredLocation(), user);
        RentOrBuyPreference preference = profileSupportService.resolvePreference(request == null ? null : request.rentOrBuy(), user);
        BigDecimal maxPrice = request != null && request.maxPrice() != null
                ? request.maxPrice()
                : preference == RentOrBuyPreference.RENT
                    ? affordability.recommendedRentMax()
                    : affordability.recommendedPurchaseMax();

        List<RecommendationResult> recommendations = listingService.getAllListings().stream()
                .filter(listing -> listing.getRentOrBuy() == preference)
                .map(listing -> scoreListing(listing, preferredLocation, maxPrice, user.getHouseholdSize(), grantMatches))
                .sorted(Comparator.comparingDouble(RecommendationResult::score).reversed())
                .limit(6)
                .toList();

        return new RecommendationResponse(recommendations);
    }

    private RecommendationResult scoreListing(
            Listing listing,
            String preferredLocation,
            BigDecimal maxPrice,
            Integer householdSize,
            GrantMatchResponse grantMatches
    ) {
        double score = 35;
        StringBuilder summary = new StringBuilder();

        if (listing.getPrice().compareTo(maxPrice) <= 0) {
            score += 35;
            summary.append("Fits your working budget. ");
        } else if (listing.getPrice().compareTo(maxPrice.multiply(BigDecimal.valueOf(1.12))) <= 0) {
            score += 18;
            summary.append("Slightly above budget but still close. ");
        }

        if (listing.getLocation().toLowerCase().contains(preferredLocation.toLowerCase())) {
            score += 20;
            summary.append("Matches your preferred location. ");
        }

        int targetBedrooms = Math.max(1, (householdSize == null ? 1 : householdSize) - 1);
        if (listing.getBedrooms() >= targetBedrooms) {
            score += 15;
        } else {
            score -= 5;
        }

        if (!grantMatches.matches().isEmpty()) {
            score += Math.min(12, grantMatches.matches().get(0).eligibilityScore() / 10.0);
            summary.append("Grant eligibility may improve the overall fit. ");
        }

        return new RecommendationResult(
                listing.getId(),
                listing.getTitle(),
                listing.getPrice(),
                listing.getLocation(),
                listing.getBedrooms(),
                listing.getBathrooms(),
                listing.getRentOrBuy(),
                Math.round(Math.min(score, 99) * 10.0) / 10.0,
                summary.toString().trim()
        );
    }
}
