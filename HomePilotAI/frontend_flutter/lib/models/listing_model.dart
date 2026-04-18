class ListingModel {
  const ListingModel({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.rentOrBuy,
  });

  final int id;
  final String title;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String rentOrBuy;

  String get formattedPrice =>
      rentOrBuy == 'RENT' ? '\$${price.toStringAsFixed(0)}/mo' : '\$${price.toStringAsFixed(0)}';

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      rentOrBuy: json['rentOrBuy'] as String,
    );
  }
}
