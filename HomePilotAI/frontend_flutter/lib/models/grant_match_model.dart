class GrantMatchModel {
  const GrantMatchModel({
    required this.programId,
    required this.programName,
    required this.rationale,
    required this.coverageAmount,
    required this.eligibilityScore,
  });

  final int programId;
  final String programName;
  final String rationale;
  final double coverageAmount;
  final double eligibilityScore;

  factory GrantMatchModel.fromJson(Map<String, dynamic> json) {
    return GrantMatchModel(
      programId: json['programId'] as int,
      programName: json['programName'] as String,
      rationale: (json['rationale'] as String?) ?? '',
      coverageAmount: (json['coverageAmount'] as num).toDouble(),
      eligibilityScore: (json['eligibilityScore'] as num).toDouble(),
    );
  }
}
