import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

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
      appBar: AppBar(title: const Text('Listings')),
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
                  ? const Center(child: Text('No listings found. Seed the database first!'))
                  : ListView.builder(
                      itemCount: _listings.length,
                      itemBuilder: (ctx, i) {
                        final l = _listings[i];
                        final isRent = l['rentOrBuy'] == 'rent';
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(isRent ? Icons.apartment : Icons.house, size: 36,
                                color: isRent ? Colors.blue : Colors.green),
                            title: Text(l['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${l['location']} • ${l['bedrooms']}bd/${l['bathrooms']}ba\n'
                                '${isRent ? "\$${l['price']}/mo" : "\$${l['price']}"}'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () => _save(l['id']),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}
