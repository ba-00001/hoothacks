import 'dart:async';

class ApiService {
  String? _token;
  int? _userId;

  void setAuth(String token, int userId) {
    _token = token;
    _userId = userId;
  }

  void clearAuth() {
    _token = null;
    _userId = null;
  }

  int? get userId => _userId;

  Future<void> _simulateProcessing({int seconds = 2}) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    await _simulateProcessing(seconds: 1);
    return {'token': 'mock_jwt_token', 'userId': 1, 'message': 'Signup successful'};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await _simulateProcessing(seconds: 1);
    return {'token': 'mock_jwt_token', 'userId': 1, 'message': 'Login successful'};
  }

  Future<Map<String, dynamic>> googleAuth(String idToken) async {
    await _simulateProcessing(seconds: 1);
    return {'token': 'mock_jwt_token', 'userId': 1, 'message': 'Google auth successful'};
  }

  Future<Map<String, dynamic>> getProfile(int userId) async {
    await _simulateProcessing(seconds: 1);
    return {
      'name': 'Demo User', 
      'incomeRange': '50k-75k', 
      'employmentStatus': 'employed', 
      'householdSize': 2, 
      'creditEstimate': 720, 
      'preferredLocation': 'Miami, FL', 
      'rentOrBuy': 'buy'
    };
  }

  Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> data) async {
    await _simulateProcessing(seconds: 1);
    return {'message': 'Profile updated'};
  }

  Future<List<dynamic>> getListings({String? type, String? location, double? maxPrice}) async {
    await _simulateProcessing(seconds: 1);
    return [
      {"id": 1, "title": "Sunny 2BR in Miami", "price": 1450.00, "location": "Miami, FL", "bedrooms": 2, "bathrooms": 1, "rentOrBuy": "rent"},
      {"id": 5, "title": "Charming Starter Home", "price": 285000.00, "location": "Homestead, FL", "bedrooms": 3, "bathrooms": 2, "rentOrBuy": "buy"},
      {"id": 8, "title": "New Build 4BR", "price": 425000.00, "location": "Boca Raton, FL", "bedrooms": 4, "bathrooms": 3, "rentOrBuy": "buy"},
      {"id": 10, "title": "Luxury Penthouse", "price": 3500.00, "location": "Miami Beach, FL", "bedrooms": 2, "bathrooms": 2, "rentOrBuy": "rent"}
    ];
  }

  Future<void> saveFavorite(int userId, int listingId) async { await _simulateProcessing(seconds: 1); }
  
  Future<List<dynamic>> getFavorites(int userId) async {
    await _simulateProcessing(seconds: 1);
    return [
       {"savedId": 1, "listing": {"id": 5, "title": "Charming Starter Home", "price": 285000.00, "location": "Homestead, FL", "bedrooms": 3, "bathrooms": 2, "rentOrBuy": "buy"}}
    ];
  }
  
  Future<void> removeFavorite(int userId, int listingId) async { await _simulateProcessing(seconds: 1); }

  Future<Map<String, dynamic>> getAffordability(int userId) async {
    await _simulateProcessing(seconds: 1);
    return {
      "userId": userId,
      "estimatedAnnualIncome": 62500,
      "householdSize": 2,
      "recommendedRentMin": 1042,
      "recommendedRentMax": 1563,
      "recommendedPurchaseMax": 250000,
      "estimatedDTI": "28%",
      "summary": "Based on your profile, your recommended monthly rent range is \$1,042–\$1,563. Max home purchase: ~\$250k.",
      "source": "AI Agent"
    };
  }

  Future<Map<String, dynamic>> getGrants(int userId) async {
    await _simulateProcessing(seconds: 1);
    return {
      "userId": userId,
      "matchedGrants": [
        {"programName": "Florida First-Time Homebuyer Program", "coverageAmount": 15000, "eligibility": "First-time buyer, income < \$75k", "matchScore": 0.95},
        {"programName": "State Housing Down Payment Grant", "coverageAmount": 10000, "eligibility": "Household size >= 2", "matchScore": 0.88}
      ],
      "totalPotentialAid": 25000,
      "source": "AI Agent"
    };
  }

  Future<Map<String, dynamic>> getRecommendations(int userId) async {
    await _simulateProcessing(seconds: 1);
    return {
      "userId": userId,
      "preference": "buy",
      "recommendations": [
        {"listingId": 5, "title": "Charming Starter Home", "price": 285000.00, "location": "Homestead, FL", "bedrooms": 3, "bathrooms": 2, "score": 0.94},
        {"listingId": 8, "title": "New Build 4BR", "price": 425000.00, "location": "Boca Raton, FL", "bedrooms": 4, "bathrooms": 3, "score": 0.82}
      ],
      "agentInsight": "These match your target budget.",
      "source": "AI Agent"
    };
  }

  Future<Map<String, dynamic>> getMortgageEstimate(int userId) async {
    await _simulateProcessing(seconds: 1);
    return {
      "userId": userId,
      "creditEstimate": 720,
      "recommendedPurchasePrice": 250000,
      "estimatedDownPayment": 25000,
      "estimatedMonthlyPayment": 1423,
      "interestRateUsed": "6.5%",
      "loanTermYears": 30,
      "readinessScore": 0.85,
      "agentInsight": "A bank is highly likely to approve you.",
      "source": "AI Simulator"
    };
  }

  Future<String> chat(String message, int userId, {String? sessionId}) async {
    await _simulateProcessing(seconds: 2);
    final lowerMsg = message.toLowerCase();
    
    if (lowerMsg.contains("afford") || lowerMsg.contains("budget") || lowerMsg.contains("what can i")) {
      return '''📊 Based on your profile, here is your Affordability Analysis:

🏠 **Purchase Budget:**
• Max Purchase Price: \$250,000
• Recommended Down Payment (10%): \$25,000
• Estimated Monthly (PITI): ~\$1,423

🏢 **Rental Budget:**
• Comfortable Range: \$1,042 - \$1,563 / month
• Max Rent (30% Rule): \$1,875 / month

Would you like me to pull up some listings in your area?''';
    } else if (lowerMsg.contains("grant") || lowerMsg.contains("qualify")) {
      return '''🎉 Great news! Based on your profile, you qualify for up to **\$25,000** in housing assistance:

💸 **Florida First-Time Homebuyer Program**
• Amount: Up to \$15,000
• Match Score: 95%
• Note: Can be applied to down payment & closing costs!

💸 **State Housing Down Payment Grant**
• Amount: Up to \$10,000
• Match Score: 88%

Should I apply these to a mortgage estimate for you?''';
    } else if (lowerMsg.contains("300k") || lowerMsg.contains("house")) {
      return '''Let's run the numbers on a \$300k home! 🧮

A \$300,000 purchase is slightly above your recommended baseline, but highly achievable if you minimize other debts.

**Estimated Breakdown (at 6.5% interest):**
• Down Payment (10%): \$30,000
• Monthly Payment: ~\$1,850 / month
• Target Income Required: ~\$75,000 / year

💡 *Pro Tip:* If we apply your \$15k grant eligibility, your out-of-pocket down payment drops to just \$15,000! Shall we browse some \$300k listings?''';
    } else if (lowerMsg.contains("rent") || lowerMsg.contains("1500")) {
      return '''I've found some excellent rental matches under \$1,500! 🏘️

Here are the top picks for you:

🥇 **Sunny 2BR in Miami**
• Price: \$1,450 / month
• 2 Bed / 1 Bath
• *Perfect fit for your budget!*

🥈 **Cozy Studio Downtown**
• Price: \$950 / month
• 0 Bed / 1 Bath
• *Great for maximizing your savings.*

Head over to the Listings tab to view photos and save your favorites!''';
    } else {
      return '''Hello! 👋 I am HomePilot AI, your personal real estate advisor.

I can analyze your financial profile to help you find the best housing options. Try asking me:
• "What can I afford?"
• "What grants do I qualify for?"
• "Can I buy a \$300k house?"''';
    }
  }

  Future<Map<String, dynamic>> resetAndSeed() async {
    await _simulateProcessing(seconds: 1);
    return {"reset": "Success", "seed": "Success"};
  }
}