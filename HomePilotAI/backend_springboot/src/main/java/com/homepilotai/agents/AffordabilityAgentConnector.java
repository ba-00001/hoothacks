package com.homepilotai.agents;

import com.homepilotai.dto.AffordabilityRequest;
import com.homepilotai.dto.AffordabilityResponse;
import com.homepilotai.models.AppUser;

public interface AffordabilityAgentConnector {

    AffordabilityResponse estimate(AppUser user, AffordabilityRequest request);
}
