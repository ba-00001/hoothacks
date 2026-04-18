package com.homepilotai.services;

import com.homepilotai.agents.MortgageAgentConnector;
import com.homepilotai.dto.MortgageEstimateRequest;
import com.homepilotai.dto.MortgageEstimateResponse;
import com.homepilotai.models.AppUser;
import com.homepilotai.models.MortgageEstimate;
import com.homepilotai.repositories.MortgageEstimateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MortgageAgentService {

    private final MortgageAgentConnector mortgageAgentConnector;
    private final MortgageEstimateRepository mortgageEstimateRepository;

    public MortgageEstimateResponse estimate(AppUser user, MortgageEstimateRequest request) {
        MortgageEstimateResponse estimate = mortgageAgentConnector.estimate(user, request);

        mortgageEstimateRepository.save(MortgageEstimate.builder()
                .user(user)
                .estimatedBudget(estimate.estimatedBudget())
                .monthlyPayment(estimate.monthlyPayment())
                .build());

        return estimate;
    }
}
