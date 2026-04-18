import '../models/listing_model.dart';
import 'api_client.dart';
import 'demo_fallbacks.dart';

class ListingService {
  ListingService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ListingModel>> getListings({
    String? location,
    String? rentOrBuy,
    String? maxPrice,
  }) async {
    try {
      final json = await _apiClient.getList(
        '/listings',
        query: {
          if (location != null && location.isNotEmpty) 'location': location,
          if (rentOrBuy != null && rentOrBuy.isNotEmpty) 'rentOrBuy': rentOrBuy,
          if (maxPrice != null && maxPrice.isNotEmpty) 'maxPrice': maxPrice,
        },
      );
      return json
          .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiConnectivityException {
      return DemoFallbacks.filterListings(
        location: location,
        rentOrBuy: rentOrBuy,
        maxPrice: maxPrice,
      );
    }
  }

  Future<List<ListingModel>> getSavedProperties() async {
    try {
      final json = await _apiClient.getList('/favorites');
      return json
          .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiConnectivityException {
      return DemoFallbacks.savedProperties();
    }
  }

  Future<void> saveFavorite(int listingId) async {
    try {
      await _apiClient.postObject('/favorites', body: {'listingId': listingId});
    } on ApiConnectivityException {
      return;
    }
  }
}
