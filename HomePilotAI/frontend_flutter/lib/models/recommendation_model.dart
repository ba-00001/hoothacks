class RecommendationModel {
  const RecommendationModel({
    required this.listingId,
    required this.title,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.rentOrBuy,
    required this.score,
    required this.fitSummary,
  });

  final int listingId;
  final String title;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String rentOrBuy;
  final double score;
  final String fitSummary;

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      listingId: json['listingId'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      rentOrBuy: json['rentOrBuy'] as String,
      score: (json['score'] as num).toDouble(),
      fitSummary: (json['fitSummary'] as String?) ?? '',
    );
  }
}
