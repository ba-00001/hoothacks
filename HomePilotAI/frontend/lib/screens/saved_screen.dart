import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../widgets/listing_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<dynamic> _saved = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId')!;
    try { _saved = await api.getFavorites(userId); } catch (e) { debugPrint('$e'); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Properties'), backgroundColor: Colors.transparent),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _saved.isEmpty
              ? const Center(child: Text('No saved properties yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _saved.length,
                  itemBuilder: (ctx, i) {
                    final l = _saved[i]['listing'];
                    return ListingCard(
                      title: l['title'],
                      location: l['location'],
                      priceLabel: '\$${l['price']}',
                      details: '${l['bedrooms']}bd / ${l['bathrooms']}ba',
                      summary: 'Remove from favorites?',
                      onSave: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await api.removeFavorite(prefs.getInt('userId')!, l['id']);
                        _load();
                      }
                    );
                  },
                ),
    );
  }
}