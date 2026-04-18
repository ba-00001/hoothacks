package com.homepilotai.dto;

import java.util.List;

public record GrantMatchResponse(
        List<GrantMatchResult> matches
) {
}
