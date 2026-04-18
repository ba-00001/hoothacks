package com.homepilotai.agents;

import com.homepilotai.dto.GrantMatchRequest;
import com.homepilotai.dto.GrantMatchResponse;
import com.homepilotai.models.AppUser;

public interface GrantMatchingAgentConnector {

    GrantMatchResponse match(AppUser user, GrantMatchRequest request);
}
