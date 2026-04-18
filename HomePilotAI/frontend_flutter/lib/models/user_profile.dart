import 'dart:convert';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.incomeRange,
    this.employmentStatus,
    this.householdSize,
    this.creditEstimate,
    this.preferredLocation,
    this.rentOrBuy,
  });

  final int id;
  final String email;
  final String? incomeRange;
  final String? employmentStatus;
  final int? householdSize;
  final int? creditEstimate;
  final String? preferredLocation;
  final String? rentOrBuy;

  bool get hasCompletedProfile =>
      (incomeRange?.isNotEmpty ?? false) &&
      (employmentStatus?.isNotEmpty ?? false) &&
      householdSize != null &&
      (preferredLocation?.isNotEmpty ?? false) &&
      (rentOrBuy?.isNotEmpty ?? false);

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String,
      incomeRange: json['incomeRange'] as String?,
      employmentStatus: json['employmentStatus'] as String?,
      householdSize: json['householdSize'] as int?,
      creditEstimate: json['creditEstimate'] as int?,
      preferredLocation: json['preferredLocation'] as String?,
      rentOrBuy: json['rentOrBuy'] as String?,
    );
  }

  factory UserProfile.fromStorage(String source) =>
      UserProfile.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toStorage() => jsonEncode({
        'id': id,
        'email': email,
        'incomeRange': incomeRange,
        'employmentStatus': employmentStatus,
        'householdSize': householdSize,
        'creditEstimate': creditEstimate,
        'preferredLocation': preferredLocation,
        'rentOrBuy': rentOrBuy,
      });
}
