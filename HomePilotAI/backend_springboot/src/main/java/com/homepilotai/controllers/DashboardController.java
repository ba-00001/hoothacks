package com.homepilotai.controllers;

import com.homepilotai.dto.DashboardResponse;
import com.homepilotai.services.DashboardService;
import com.homepilotai.services.UserProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;
    private final UserProfileService userProfileService;

    @GetMapping
    public DashboardResponse getDashboard(Authentication authentication) {
        return dashboardService.buildDashboard(userProfileService.getCurrentUser(authentication));
    }
}
