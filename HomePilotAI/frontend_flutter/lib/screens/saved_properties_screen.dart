import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing_model.dart';
import '../services/listing_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/listing_card.dart';

class SavedPropertiesScreen extends StatelessWidget {
  const SavedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ListingModel>>(
      future: context.read<ListingService>().getSavedProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EmptyState(snapshot.error.toString().replaceFirst('Exception: ', ''));
        }

        final listings = snapshot.data!;
        if (listings.isEmpty) {
          return const EmptyState('You have not saved any properties yet.');
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: listings.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = listings[index];
            return ListingCard(
              title: item.title,
              location: item.location,
              priceLabel: item.formattedPrice,
              details: '${item.bedrooms} bd • ${item.bathrooms} ba',
            );
          },
        );
      },
    );
  }
}
