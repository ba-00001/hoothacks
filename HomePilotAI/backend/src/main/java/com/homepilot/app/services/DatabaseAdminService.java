package com.homepilot.app.services;

import com.homepilot.app.models.*;
import com.homepilot.app.repositories.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;

@Service
public class DatabaseAdminService {

    @Autowired private UserRepository userRepository;
    @Autowired private ListingRepository listingRepository;
    @Autowired private GrantProgramRepository grantProgramRepository;
    @Autowired private RecommendationRepository recommendationRepository;
    @Autowired private SavedPropertyRepository savedPropertyRepository;
    @Autowired private MortgageEstimateRepository mortgageEstimateRepository;

    @Transactional
    public String resetAllTables() {
        mortgageEstimateRepository.deleteAll();
        savedPropertyRepository.deleteAll();
        recommendationRepository.deleteAll();
        grantProgramRepository.deleteAll();
        listingRepository.deleteAll();
        userRepository.deleteAll();
        return "All tables cleared successfully.";
    }

    @Transactional
    public String seedDatabase() {
        // Seed listings
        String[][] listingsData = {
            {"Sunny 2BR in Miami", "1450.00", "Miami, FL", "2", "1", "rent"},
            {"Cozy Studio Downtown", "950.00", "Miami, FL", "0", "1", "rent"},
            {"Spacious 3BR Family Home", "2100.00", "Fort Lauderdale, FL", "3", "2", "rent"},
            {"Modern 1BR in Brickell", "1800.00", "Miami, FL", "1", "1", "rent"},
            {"Charming Starter Home", "285000.00", "Homestead, FL", "3", "2", "buy"},
            {"Lakefront Condo", "195000.00", "Pembroke Pines, FL", "2", "2", "buy"},
            {"Renovated Townhouse", "340000.00", "Coral Springs, FL", "3", "2", "buy"},
            {"New Build 4BR", "425000.00", "Boca Raton, FL", "4", "3", "buy"},
            {"Affordable 2BR Apartment", "1100.00", "Hialeah, FL", "2", "1", "rent"},
            {"Luxury Penthouse", "3500.00", "Miami Beach, FL", "2", "2", "rent"},
        };

        for (String[] d : listingsData) {
            Listing l = new Listing();
            l.setTitle(d[0]);
            l.setPrice(new BigDecimal(d[1]));
            l.setLocation(d[2]);
            l.setBedrooms(Integer.parseInt(d[3]));
            l.setBathrooms(Integer.parseInt(d[4]));
            l.setRentOrBuy(d[5]);
            l.setDescription("Mock listing for MVP demo.");
            listingRepository.save(l);
        }

        // Seed grant programs
        GrantProgram g1 = new GrantProgram();
        g1.setProgramName("Florida First-Time Homebuyer Program");
        g1.setEligibilityRules("First-time buyer, FL resident, income below $75,000");
        g1.setCoverageAmount(new BigDecimal("15000.00"));
        grantProgramRepository.save(g1);

        GrantProgram g2 = new GrantProgram();
        g2.setProgramName("State Housing Down Payment Assistance");
        g2.setEligibilityRules("Household size >= 2, income below $100,000");
        g2.setCoverageAmount(new BigDecimal("10000.00"));
        grantProgramRepository.save(g2);

        GrantProgram g3 = new GrantProgram();
        g3.setProgramName("Student Housing Support Grant");
        g3.setEligibilityRules("Currently enrolled college student");
        g3.setCoverageAmount(new BigDecimal("5000.00"));
        grantProgramRepository.save(g3);

        GrantProgram g4 = new GrantProgram();
        g4.setProgramName("Emergency Rental Assistance Program");
        g4.setEligibilityRules("Income below 50% AMI, at risk of eviction");
        g4.setCoverageAmount(new BigDecimal("7500.00"));
        grantProgramRepository.save(g4);

        return "Database seeded with " + listingsData.length + " listings and 4 grant programs.";
    }
}
