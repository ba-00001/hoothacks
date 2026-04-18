import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../widgets/listing_card.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});
  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<dynamic> _listings = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _listings = await api.getListings(type: _filter == 'all' ? null : _filter);
    } catch (e) { debugPrint('$e'); }
    setState(() => _loading = false);
  }

  Future<void> _save(int listingId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId')!;
    await api.saveFavorite(userId, listingId);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to favorites!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listings'), backgroundColor: Colors.transparent),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'rent', label: Text('Rent')),
              ButtonSegment(value: 'buy', label: Text('Buy')),
            ],
            selected: {_filter},
            onSelectionChanged: (v) { _filter = v.first; _load(); },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _listings.isEmpty
                  ? const Center(child: Text('No listings found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _listings.length,
                      itemBuilder: (ctx, i) {
                        final l = _listings[i];
                        final isRent = l['rentOrBuy'] == 'rent';
                        return ListingCard(
                          title: l['title'],
                          location: l['location'],
                          priceLabel: isRent ? "\$${l['price']}/mo" : "\$${l['price']}",
                          details: '${l['bedrooms']}bd / ${l['bathrooms']}ba',
                          onSave: () => _save(l['id']),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}