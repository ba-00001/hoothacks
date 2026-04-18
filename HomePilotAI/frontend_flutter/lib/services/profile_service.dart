import '../models/user_profile.dart';
import 'api_client.dart';
import 'demo_fallbacks.dart';

class ProfileService {
  ProfileService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> getProfile() async {
    try {
      final json = await _apiClient.getObject('/profile');
      return UserProfile.fromJson(json);
    } on ApiConnectivityException {
      return _apiClient.session.user ?? DemoFallbacks.demoUser;
    }
  }

  Future<UserProfile> updateProfile({
    required String incomeRange,
    required String employmentStatus,
    required int householdSize,
    int? creditEstimate,
    required String preferredLocation,
    required String rentOrBuy,
  }) async {
    try {
      final json = await _apiClient.putObject(
        '/profile',
        body: {
          'incomeRange': incomeRange,
          'employmentStatus': employmentStatus,
          'householdSize': householdSize,
          'creditEstimate': creditEstimate,
          'preferredLocation': preferredLocation,
          'rentOrBuy': rentOrBuy,
        },
      );
      return UserProfile.fromJson(json);
    } on ApiConnectivityException {
      final currentUser = _apiClient.session.user ?? DemoFallbacks.demoUser;
      return DemoFallbacks.updatedUser(
        id: currentUser.id,
        email: currentUser.email,
        incomeRange: incomeRange,
        employmentStatus: employmentStatus,
        householdSize: householdSize,
        creditEstimate: creditEstimate,
        preferredLocation: preferredLocation,
        rentOrBuy: rentOrBuy,
      );
    }
  }
}
