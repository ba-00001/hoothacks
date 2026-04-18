import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recommendation_model.dart';
import '../services/ai_service.dart';
import '../services/listing_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/listing_card.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  Future<void> _save(BuildContext context, int listingId) async {
    await context.read<ListingService>().saveFavorite(listingId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved to favorites')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecommendationModel>>(
      future: context.read<AiService>().getRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EmptyState(
            snapshot.error.toString().replaceFirst('Exception: ', ''),
          );
        }

        final recommendations = snapshot.data!;
        if (recommendations.isEmpty) {
          return const EmptyState('No recommendations available yet.');
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: recommendations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = recommendations[index];
            return ListingCard(
              title: item.title,
              location: item.location,
              priceLabel: item.rentOrBuy == 'RENT'
                  ? '\$${item.price.toStringAsFixed(0)}/mo'
                  : '\$${item.price.toStringAsFixed(0)}',
              details: '${item.bedrooms} bd • ${item.bathrooms} ba',
              scoreLabel: item.score.toStringAsFixed(1),
              summary: item.fitSummary,
              onSave: () => _save(context, item.listingId),
            );
          },
        );
      },
    );
  }
}
