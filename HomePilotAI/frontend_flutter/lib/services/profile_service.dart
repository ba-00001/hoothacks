import '../models/user_profile.dart';
import 'api_client.dart';

class ProfileService {
  ProfileService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> getProfile() async {
    final json = await _apiClient.getObject('/profile');
    return UserProfile.fromJson(json);
  }

  Future<UserProfile> updateProfile({
    required String incomeRange,
    required String employmentStatus,
    required int householdSize,
    int? creditEstimate,
    required String preferredLocation,
    required String rentOrBuy,
  }) async {
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
  }
}
