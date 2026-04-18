import '../models/dashboard_model.dart';
import '../models/grant_match_model.dart';
import '../models/mortgage_estimate_model.dart';
import '../models/recommendation_model.dart';
import 'api_client.dart';

class AiService {
  AiService(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardModel> getDashboard() async {
    final json = await _apiClient.getObject('/dashboard');
    return DashboardModel.fromJson(json);
  }

  Future<List<GrantMatchModel>> getGrants() async {
    final json = await _apiClient.postObject('/ai/grants');
    final matches = json['matches'] as List<dynamic>;
    return matches
        .map((item) => GrantMatchModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecommendationModel>> getRecommendations() async {
    final json = await _apiClient.postObject('/ai/recommendations');
    final recommendations = json['recommendations'] as List<dynamic>;
    return recommendations
        .map((item) => RecommendationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MortgageEstimateModel> getMortgageEstimate({
    double? downPayment,
  }) async {
    final json = await _apiClient.postObject(
      '/ai/mortgage-estimate',
      body: downPayment == null ? null : {'downPayment': downPayment},
    );
    return MortgageEstimateModel.fromJson(json);
  }
}
