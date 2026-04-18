class AffordabilityModel {
  const AffordabilityModel({
    required this.message,
    required this.recommendedRentMin,
    required this.recommendedRentMax,
    required this.recommendedPurchaseMin,
    required this.recommendedPurchaseMax,
    required this.estimatedDebtToIncomeRatio,
    required this.recommendedHousingBudget,
  });

  final String message;
  final double recommendedRentMin;
  final double recommendedRentMax;
  final double recommendedPurchaseMin;
  final double recommendedPurchaseMax;
  final double estimatedDebtToIncomeRatio;
  final double recommendedHousingBudget;

  factory AffordabilityModel.fromJson(Map<String, dynamic> json) {
    return AffordabilityModel(
      message: json['message'] as String,
      recommendedRentMin: (json['recommendedRentMin'] as num).toDouble(),
      recommendedRentMax: (json['recommendedRentMax'] as num).toDouble(),
      recommendedPurchaseMin:
          (json['recommendedPurchaseMin'] as num).toDouble(),
      recommendedPurchaseMax:
          (json['recommendedPurchaseMax'] as num).toDouble(),
      estimatedDebtToIncomeRatio:
          (json['estimatedDebtToIncomeRatio'] as num).toDouble(),
      recommendedHousingBudget:
          (json['recommendedHousingBudget'] as num).toDouble(),
    );
  }
}
