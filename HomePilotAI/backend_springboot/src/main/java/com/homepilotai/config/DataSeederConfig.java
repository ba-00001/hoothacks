package com.homepilotai.config;

import com.homepilotai.models.GrantProgram;
import com.homepilotai.models.Listing;
import com.homepilotai.models.RentOrBuyPreference;
import com.homepilotai.models.AppUser;
import com.homepilotai.repositories.AppUserRepository;
import com.homepilotai.repositories.GrantProgramRepository;
import com.homepilotai.repositories.ListingRepository;
import java.math.BigDecimal;
import java.util.List;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class DataSeederConfig {

    @Bean
    CommandLineRunner seedData(
            ListingRepository listingRepository,
            GrantProgramRepository grantProgramRepository,
            AppUserRepository appUserRepository,
            PasswordEncoder passwordEncoder
    ) {
        return args -> {
            if (!appUserRepository.existsByEmail("demo@homepilot.ai")) {
                appUserRepository.save(AppUser.builder()
                        .email("demo@homepilot.ai")
                        .password(passwordEncoder.encode("HomePilot123!"))
                        .incomeRange("52000-68000")
                        .employmentStatus("Full-time")
                        .householdSize(2)
                        .creditEstimate(690)
                        .preferredLocation("Atlanta, GA")
                        .rentOrBuy(RentOrBuyPreference.BUY)
                        .build());
            }

            if (listingRepository.count() == 0) {
                listingRepository.saveAll(List.of(
                        Listing.builder().title("West End Studio Loft").price(BigDecimal.valueOf(1180)).location("Atlanta, GA").bedrooms(1).bathrooms(1).rentOrBuy(RentOrBuyPreference.RENT).build(),
                        Listing.builder().title("Midtown Family Rental").price(BigDecimal.valueOf(1650)).location("Atlanta, GA").bedrooms(3).bathrooms(2).rentOrBuy(RentOrBuyPreference.RENT).build(),
                        Listing.builder().title("Charlotte Starter Apartment").price(BigDecimal.valueOf(1325)).location("Charlotte, NC").bedrooms(2).bathrooms(1).rentOrBuy(RentOrBuyPreference.RENT).build(),
                        Listing.builder().title("Nashville Student Housing").price(BigDecimal.valueOf(980)).location("Nashville, TN").bedrooms(1).bathrooms(1).rentOrBuy(RentOrBuyPreference.RENT).build(),
                        Listing.builder().title("Orlando Duplex Rental").price(BigDecimal.valueOf(1495)).location("Orlando, FL").bedrooms(2).bathrooms(2).rentOrBuy(RentOrBuyPreference.RENT).build(),
                        Listing.builder().title("Savannah First Home").price(BigDecimal.valueOf(182000)).location("Savannah, GA").bedrooms(3).bathrooms(2).rentOrBuy(RentOrBuyPreference.BUY).build(),
                        Listing.builder().title("Raleigh Townhome Opportunity").price(BigDecimal.valueOf(238000)).location("Raleigh, NC").bedrooms(3).bathrooms(3).rentOrBuy(RentOrBuyPreference.BUY).build(),
                        Listing.builder().title("Columbus Affordable Cottage").price(BigDecimal.valueOf(156000)).location("Columbus, OH").bedrooms(2).bathrooms(1).rentOrBuy(RentOrBuyPreference.BUY).build(),
                        Listing.builder().title("Jacksonville FHA Ready Home").price(BigDecimal.valueOf(214000)).location("Jacksonville, FL").bedrooms(3).bathrooms(2).rentOrBuy(RentOrBuyPreference.BUY).build(),
                        Listing.builder().title("Detroit Equity Builder Home").price(BigDecimal.valueOf(128000)).location("Detroit, MI").bedrooms(3).bathrooms(1).rentOrBuy(RentOrBuyPreference.BUY).build()
                ));
            }

            if (grantProgramRepository.count() == 0) {
                grantProgramRepository.saveAll(List.of(
                        GrantProgram.builder().programName("First Step Homebuyer Grant").eligibilityRules("type=BUY;maxIncome=85000;minCredit=620;location=ANY;tag=first-time-buyer").coverageAmount(BigDecimal.valueOf(12000)).build(),
                        GrantProgram.builder().programName("State Rental Bridge Support").eligibilityRules("type=RENT;maxIncome=55000;householdMin=1;location=ANY;tag=rental-assistance").coverageAmount(BigDecimal.valueOf(4500)).build(),
                        GrantProgram.builder().programName("Family Stability Housing Fund").eligibilityRules("type=RENT;maxIncome=70000;householdMin=3;location=ANY;tag=family").coverageAmount(BigDecimal.valueOf(6000)).build(),
                        GrantProgram.builder().programName("Student Housing Success Program").eligibilityRules("type=RENT;maxIncome=45000;location=ANY;tag=student").coverageAmount(BigDecimal.valueOf(3000)).build(),
                        GrantProgram.builder().programName("Southeast Down Payment Boost").eligibilityRules("type=BUY;maxIncome=95000;minCredit=600;location=GA;tag=regional").coverageAmount(BigDecimal.valueOf(10000)).build()
                ));
            }
        };
    }
}
