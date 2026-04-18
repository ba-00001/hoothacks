package com.homepilotai.services;

import com.homepilotai.agents.AffordabilityAgentConnector;
import com.homepilotai.dto.AffordabilityRequest;
import com.homepilotai.dto.AffordabilityResponse;
import com.homepilotai.models.AppUser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AffordabilityAgentService {

    private final AffordabilityAgentConnector affordabilityAgentConnector;

    public AffordabilityResponse estimate(AppUser user, AffordabilityRequest request) {
        return affordabilityAgentConnector.estimate(user, request);
    }
}
