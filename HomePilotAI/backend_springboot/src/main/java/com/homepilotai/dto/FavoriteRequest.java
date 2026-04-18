package com.homepilotai.dto;

import jakarta.validation.constraints.NotNull;

public record FavoriteRequest(
        @NotNull Long listingId
) {
}
