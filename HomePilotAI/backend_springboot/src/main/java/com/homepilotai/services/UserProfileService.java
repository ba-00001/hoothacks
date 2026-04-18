package com.homepilotai.services;

import com.homepilotai.dto.ProfileSetupRequest;
import com.homepilotai.dto.UserProfileResponse;
import com.homepilotai.models.AppUser;
import com.homepilotai.repositories.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final AppUserRepository appUserRepository;

    public AppUser getCurrentUser(Authentication authentication) {
        return appUserRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }

    public UserProfileResponse getCurrentUserProfile(Authentication authentication) {
        return UserProfileResponse.from(getCurrentUser(authentication));
    }

    public UserProfileResponse updateProfile(Authentication authentication, ProfileSetupRequest request) {
        AppUser user = getCurrentUser(authentication);
        user.setIncomeRange(request.incomeRange());
        user.setEmploymentStatus(request.employmentStatus());
        user.setHouseholdSize(request.householdSize());
        user.setCreditEstimate(request.creditEstimate());
        user.setPreferredLocation(request.preferredLocation());
        user.setRentOrBuy(request.rentOrBuy());
        return UserProfileResponse.from(appUserRepository.save(user));
    }
}
