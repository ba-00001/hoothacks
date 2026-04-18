import '../models/affordability_model.dart';
import '../models/auth_response.dart';
import '../models/dashboard_model.dart';
import '../models/grant_match_model.dart';
import '../models/listing_model.dart';
import '../models/mortgage_estimate_model.dart';
import '../models/recommendation_model.dart';
import '../models/user_profile.dart';

class DemoFallbacks {
  static const demoEmail = 'demo@homepilot.ai';
  static const demoPassword = 'HomePilot123!';
  static const offlineToken = 'offline-demo-token';
  static const offlineModeLabel = 'Offline demo mode';

  static bool matchesDemoCredentials({
    required String email,
    required String password,
  }) {
    return email.trim().toLowerCase() == demoEmail && password == demoPassword;
  }

  static AuthResponse authResponse() {
    return AuthResponse(token: offlineToken, user: demoUser);
  }

  static const UserProfile demoUser = UserProfile(
    id: 1,
    email: demoEmail,
    incomeRange: '52000-68000',
    employmentStatus: 'Full-time',
    householdSize: 2,
    creditEstimate: 690,
    preferredLocation: 'Atlanta, GA',
    rentOrBuy: 'BUY',
  );

  static DashboardModel dashboard() {
    return DashboardModel(
      affordability: const AffordabilityModel(
        message:
            'Based on the demo household profile, the recommended monthly rent range is \$1215-\$1540 and the most realistic purchase band starts around \$185000.',
        recommendedRentMin: 1215,
        recommendedRentMax: 1540,
        recommendedPurchaseMin: 185000,
        recommendedPurchaseMax: 242000,
        estimatedDebtToIncomeRatio: 0.24,
        recommendedHousingBudget: 1380,
      ),
      mortgageEstimate: mortgageEstimate(),
      grants: grants(),
      topListings: recommendations(),
    );
  }

  static List<GrantMatchModel> grants() {
    return const [
      GrantMatchModel(
        programId: 1,
        programName: 'First Step Homebuyer Grant',
        rationale:
            'Strong fit for a first-time buyer profile with stable income and qualifying credit.',
        coverageAmount: 12000,
        eligibilityScore: 91,
      ),
      GrantMatchModel(
        programId: 5,
        programName: 'Southeast Down Payment Boost',
        rationale:
            'Atlanta preference and target income range line up with this regional assistance fund.',
        coverageAmount: 10000,
        eligibilityScore: 88,
      ),
      GrantMatchModel(
        programId: 2,
        programName: 'State Rental Bridge Support',
        rationale:
            'Still useful as a fallback path if the household chooses to rent before buying.',
        coverageAmount: 4500,
        eligibilityScore: 72,
      ),
    ];
  }

  static List<RecommendationModel> recommendations() {
    return const [
      RecommendationModel(
        listingId: 6,
        title: 'Savannah First Home',
        price: 182000,
        location: 'Savannah, GA',
        bedrooms: 3,
        bathrooms: 2,
        rentOrBuy: 'BUY',
        score: 93,
        fitSummary:
            'Within the recommended budget band and strengthened by down payment grant support.',
      ),
      RecommendationModel(
        listingId: 9,
        title: 'Jacksonville FHA Ready Home',
        price: 214000,
        location: 'Jacksonville, FL',
        bedrooms: 3,
        bathrooms: 2,
        rentOrBuy: 'BUY',
        score: 86,
        fitSummary:
            'A realistic step-up option with solid credit compatibility and manageable monthly cost.',
      ),
      RecommendationModel(
        listingId: 1,
        title: 'West End Studio Loft',
        price: 1180,
        location: 'Atlanta, GA',
        bedrooms: 1,
        bathrooms: 1,
        rentOrBuy: 'RENT',
        score: 78,
        fitSummary:
            'Useful lower-risk rental fallback while saving for a larger purchase down payment.',
      ),
    ];
  }

  static MortgageEstimateModel mortgageEstimate({double? downPayment}) {
    final adjustment = (downPayment ?? 0) / 10000;
    return MortgageEstimateModel(
      estimatedBudget: 215000 + (adjustment * 2500),
      monthlyPayment: 1425 - (adjustment * 18),
      readinessScore: 81,
      recommendedPurchaseMin: 185000,
      recommendedPurchaseMax: 242000,
      summary:
          'The demo household appears mortgage-ready with moderate grant support and a manageable monthly payment target.',
    );
  }

  static const _img = 'https://picsum.photos/seed';

  static List<ListingModel> listings() {
    return const [
      ListingModel(
        id: 1,
        title: 'West End Studio Loft',
        price: 1180,
        location: 'Atlanta, GA',
        bedrooms: 1,
        bathrooms: 1,
        rentOrBuy: 'RENT',
        description: 'Bright studio loft in walkable West End with exposed brick and updated kitchen.',
        imageUrl: '$_img/west-end-studio/600/400',
      ),
      ListingModel(
        id: 2,
        title: 'Midtown Family Rental',
        price: 1650,
        location: 'Atlanta, GA',
        bedrooms: 3,
        bathrooms: 2,
        rentOrBuy: 'RENT',
        description: 'Spacious 3-bedroom near Piedmont Park, minutes from Beltline trail access.',
        imageUrl: '$_img/midtown-family/600/400',
      ),
      ListingModel(
        id: 3,
        title: 'Charlotte Starter Apartment',
        price: 1325,
        location: 'Charlotte, NC',
        bedrooms: 2,
        bathrooms: 1,
        rentOrBuy: 'RENT',
        description: 'Modern 2-bed in South End corridor, close to light rail and dining.',
        imageUrl: '$_img/charlotte-apt/600/400',
      ),
      ListingModel(
        id: 4,
        title: 'Nashville Student Housing',
        price: 980,
        location: 'Nashville, TN',
        bedrooms: 1,
        bathrooms: 1,
        rentOrBuy: 'RENT',
        description: 'Affordable 1-bed near Vanderbilt and Belmont, utilities included.',
        imageUrl: '$_img/nashville-student/600/400',
      ),
      ListingModel(
        id: 5,
        title: 'Orlando Duplex Rental',
        price: 1495,
        location: 'Orlando, FL',
        bedrooms: 2,
        bathrooms: 2,
        rentOrBuy: 'RENT',
        description: 'Private duplex unit with fenced yard and covered parking, no HOA.',
        imageUrl: '$_img/orlando-duplex/600/400',
      ),
      ListingModel(
        id: 6,
        title: 'Savannah First Home',
        price: 182000,
        location: 'Savannah, GA',
        bedrooms: 3,
        bathrooms: 2,
        rentOrBuy: 'BUY',
        description: 'Move-in ready craftsman with original hardwoods, updated HVAC, and large back porch.',
        imageUrl: '$_img/savannah-home/600/400',
      ),
      ListingModel(
        id: 7,
        title: 'Raleigh Townhome Opportunity',
        price: 238000,
        location: 'Raleigh, NC',
        bedrooms: 3,
        bathrooms: 3,
        rentOrBuy: 'BUY',
        description: 'End-unit townhome in North Raleigh, attached garage and community pool.',
        imageUrl: '$_img/raleigh-townhome/600/400',
      ),
      ListingModel(
        id: 8,
        title: 'Columbus Affordable Cottage',
        price: 156000,
        location: 'Columbus, OH',
        bedrooms: 2,
        bathrooms: 1,
        rentOrBuy: 'BUY',
        description: 'Charming bungalow on a quiet street, updated kitchen and new roof.',
        imageUrl: '$_img/columbus-cottage/600/400',
      ),
      ListingModel(
        id: 9,
        title: 'Jacksonville FHA Ready Home',
        price: 214000,
        location: 'Jacksonville, FL',
        bedrooms: 3,
        bathrooms: 2,
        rentOrBuy: 'BUY',
        description: 'FHA-eligible single-family home in Mandarin, large lot and screened lanai.',
        imageUrl: '$_img/jacksonville-fha/600/400',
      ),
      ListingModel(
        id: 10,
        title: 'Detroit Equity Builder Home',
        price: 128000,
        location: 'Detroit, MI',
        bedrooms: 3,
        bathrooms: 1,
        rentOrBuy: 'BUY',
        description: 'Solid brick colonial in Rosedale Park, fully remodeled interior with equity upside.',
        imageUrl: '$_img/detroit-equity/600/400',
      ),
    ];
  }

  static List<ListingModel> filterListings({
    String? location,
    String? rentOrBuy,
    String? maxPrice,
  }) {
    final requestedMaxPrice = double.tryParse(maxPrice ?? '');
    return listings().where((listing) {
      final matchesLocation =
          location == null ||
          location.isEmpty ||
          listing.location.toLowerCase().contains(location.toLowerCase());
      final matchesType =
          rentOrBuy == null ||
          rentOrBuy.isEmpty ||
          listing.rentOrBuy == rentOrBuy;
      final matchesPrice =
          requestedMaxPrice == null || listing.price <= requestedMaxPrice;
      return matchesLocation && matchesType && matchesPrice;
    }).toList();
  }

  static List<ListingModel> savedProperties() {
    return listings()
        .where((listing) => listing.id == 6 || listing.id == 9)
        .toList();
  }

  static UserProfile updatedUser({
    required int id,
    required String email,
    required String incomeRange,
    required String employmentStatus,
    required int householdSize,
    int? creditEstimate,
    required String preferredLocation,
    required String rentOrBuy,
  }) {
    return UserProfile(
      id: id,
      email: email,
      incomeRange: incomeRange,
      employmentStatus: employmentStatus,
      householdSize: householdSize,
      creditEstimate: creditEstimate,
      preferredLocation: preferredLocation,
      rentOrBuy: rentOrBuy,
    );
  }
}
