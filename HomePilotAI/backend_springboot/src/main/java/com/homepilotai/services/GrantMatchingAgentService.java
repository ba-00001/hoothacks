package com.homepilotai.services;

import com.homepilotai.agents.GrantMatchingAgentConnector;
import com.homepilotai.dto.GrantMatchRequest;
import com.homepilotai.dto.GrantMatchResponse;
import com.homepilotai.models.AppUser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GrantMatchingAgentService {

    private final GrantMatchingAgentConnector grantMatchingAgentConnector;

    public GrantMatchResponse match(AppUser user, GrantMatchRequest request) {
        return grantMatchingAgentConnector.match(user, request);
    }
}
