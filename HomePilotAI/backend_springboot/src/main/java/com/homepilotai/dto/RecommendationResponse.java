package com.homepilotai.dto;

import java.util.List;

public record RecommendationResponse(
        List<RecommendationResult> recommendations
) {
}
