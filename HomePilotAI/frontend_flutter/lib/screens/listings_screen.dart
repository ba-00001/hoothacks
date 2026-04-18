import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing_model.dart';
import '../services/listing_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/listing_card.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  String? _rentOrBuy;
  late Future<List<ListingModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadListings();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<List<ListingModel>> _loadListings() {
    return context.read<ListingService>().getListings(
      location: _locationController.text.trim(),
      maxPrice: _priceController.text.trim(),
      rentOrBuy: _rentOrBuy,
    );
  }

  Future<void> _saveFavorite(int listingId) async {
    await context.read<ListingService>().saveFavorite(listingId);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved to favorites')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Filter by location',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max price'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _rentOrBuy,
                decoration: const InputDecoration(labelText: 'Rent or buy'),
                items: const [
                  DropdownMenuItem(value: 'RENT', child: Text('Rent')),
                  DropdownMenuItem(value: 'BUY', child: Text('Buy')),
                ],
                onChanged: (value) => setState(() => _rentOrBuy = value),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _future = _loadListings()),
                  child: const Text('Search listings'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ListingModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return EmptyState(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                );
              }

              final listings = snapshot.data!;
              if (listings.isEmpty) {
                return const EmptyState('No listings matched those filters.');
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: listings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = listings[index];
                  return ListingCard(
                    title: item.title,
                    location: item.location,
                    priceLabel: item.formattedPrice,
                    details: '${item.bedrooms} bd • ${item.bathrooms} ba',
                    onSave: () => _saveFavorite(item.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
