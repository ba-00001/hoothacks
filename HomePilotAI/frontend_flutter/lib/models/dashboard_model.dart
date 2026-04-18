import 'affordability_model.dart';
import 'grant_match_model.dart';
import 'mortgage_estimate_model.dart';
import 'recommendation_model.dart';

class DashboardModel {
  const DashboardModel({
    required this.affordability,
    required this.mortgageEstimate,
    required this.grants,
    required this.topListings,
  });

  final AffordabilityModel affordability;
  final MortgageEstimateModel mortgageEstimate;
  final List<GrantMatchModel> grants;
  final List<RecommendationModel> topListings;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      affordability: AffordabilityModel.fromJson(
        json['affordability'] as Map<String, dynamic>,
      ),
      mortgageEstimate: MortgageEstimateModel.fromJson(
        json['mortgageEstimate'] as Map<String, dynamic>,
      ),
      grants:
          ((json['grants'] as Map<String, dynamic>)['matches'] as List<dynamic>)
              .map(
                (item) =>
                    GrantMatchModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      topListings: (json['topListings'] as List<dynamic>)
          .map(
            (item) =>
                RecommendationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
