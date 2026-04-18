class MortgageEstimateModel {
  const MortgageEstimateModel({
    required this.estimatedBudget,
    required this.monthlyPayment,
    required this.readinessScore,
    required this.recommendedPurchaseMin,
    required this.recommendedPurchaseMax,
    required this.summary,
  });

  final double estimatedBudget;
  final double monthlyPayment;
  final int readinessScore;
  final double recommendedPurchaseMin;
  final double recommendedPurchaseMax;
  final String summary;

  factory MortgageEstimateModel.fromJson(Map<String, dynamic> json) {
    return MortgageEstimateModel(
      estimatedBudget: (json['estimatedBudget'] as num).toDouble(),
      monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
      readinessScore: json['readinessScore'] as int,
      recommendedPurchaseMin: (json['recommendedPurchaseMin'] as num)
          .toDouble(),
      recommendedPurchaseMax: (json['recommendedPurchaseMax'] as num)
          .toDouble(),
      summary: json['summary'] as String,
    );
  }
}
