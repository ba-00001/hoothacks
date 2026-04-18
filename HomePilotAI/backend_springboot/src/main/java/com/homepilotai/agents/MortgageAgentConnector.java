package com.homepilotai.agents;

import com.homepilotai.dto.MortgageEstimateRequest;
import com.homepilotai.dto.MortgageEstimateResponse;
import com.homepilotai.models.AppUser;

public interface MortgageAgentConnector {

    MortgageEstimateResponse estimate(AppUser user, MortgageEstimateRequest request);
}
