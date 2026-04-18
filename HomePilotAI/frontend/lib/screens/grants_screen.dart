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
      appBar: AppBar(title: const Text('Grant Eligibility'), backgroundColor: Colors.transparent),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(20), children: [
              Text(
                'Total Potential Aid: \$${_data?['totalPotentialAid'] ?? 0}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...grants.map((g) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g['programName'], style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text(g['eligibility']),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        children: [
                          Chip(label: Text('\$${g['coverageAmount']} coverage')),
                          Chip(label: Text('${(g['matchScore'] * 100).round()}% match')),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ]),
    );
  }
}