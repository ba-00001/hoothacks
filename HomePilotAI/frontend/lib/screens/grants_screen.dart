import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class GrantsScreen extends StatefulWidget {
  const GrantsScreen({super.key});
  @override
  State<GrantsScreen> createState() => _GrantsScreenState();
}

class _GrantsScreenState extends State<GrantsScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    try { _data = await api.getGrants(prefs.getInt('userId')!); } catch (e) { debugPrint('$e'); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final grants = _data?['matchedGrants'] as List? ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Grant Eligibility')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Total Potential Aid: \$${_data?['totalPotentialAid'] ?? 0}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              ...grants.map((g) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.card_giftcard, color: Colors.green),
                  title: Text(g['programName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Coverage: \$${g['coverageAmount']}\n${g['eligibility']}'),
                  isThreeLine: true,
                  trailing: Text('${(g['matchScore'] * 100).round()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 12),
              Text('Source: ${_data?['source'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
    );
  }
}
