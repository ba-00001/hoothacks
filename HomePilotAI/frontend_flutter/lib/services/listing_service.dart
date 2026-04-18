import '../models/listing_model.dart';
import 'api_client.dart';

class ListingService {
  ListingService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ListingModel>> getListings({
    String? location,
    String? rentOrBuy,
    String? maxPrice,
  }) async {
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
  }

  Future<List<ListingModel>> getSavedProperties() async {
    final json = await _apiClient.getList('/favorites');
    return json
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorite(int listingId) async {
    await _apiClient.postObject('/favorites', body: {'listingId': listingId});
  }
}
