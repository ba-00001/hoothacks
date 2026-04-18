import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'login_screen.dart';
import 'listings_screen.dart';
import 'grants_screen.dart';
import 'mortgage_screen.dart';
import 'saved_screen.dart';
import 'profile_setup_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _affordability;
  Map<String, dynamic>? _grants;
  Map<String, dynamic>? _recommendations;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId')!;
      final results = await Future.wait([
        api.getAffordability(userId),
        api.getGrants(userId),
        api.getRecommendations(userId),
      ]);
      setState(() {
        _affordability = results[0];
        _grants = results[1];
        _recommendations = results[2];
      });
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    api.clearAuth();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePilot AI'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            if (mounted) Navigator.push(context, MaterialPageRoute(
              builder: (_) => ProfileSetupScreen(userId: prefs.getInt('userId')!)));
          }),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                // Affordability Card
                _buildCard(
                  icon: Icons.attach_money, title: 'Affordability',
                  color: cs.primaryContainer,
                  child: Text(_affordability?['summary'] ?? 'Complete your profile for analysis',
                      style: const TextStyle(fontSize: 15)),
                ),
                const SizedBox(height: 12),

                // Grants Card
                _buildCard(
                  icon: Icons.card_giftcard, title: 'Eligible Grants',
                  color: cs.secondaryContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_grants?['matchedGrants'] != null)
                        ...(_grants!['matchedGrants'] as List).take(2).map((g) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• ${g['programName']} — \$${g['coverageAmount']}', style: const TextStyle(fontSize: 14)),
                        )),
                      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrantsScreen())),
                        child: const Text('View all grants →')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Top Recommendations
                _buildCard(
                  icon: Icons.star, title: 'Top Picks',
                  color: cs.tertiaryContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_recommendations?['recommendations'] != null)
                        ...(_recommendations!['recommendations'] as List).take(3).map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• ${r['title']} — \$${r['price']} (${(r['score'] * 100).round()}% match)',
                              style: const TextStyle(fontSize: 14)),
                        )),
                      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingsScreen())),
                        child: const Text('Browse all listings →')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Action Grid
                Row(children: [
                  _actionButton(Icons.search, 'Listings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingsScreen()))),
                  const SizedBox(width: 12),
                  _actionButton(Icons.favorite, 'Saved', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScreen()))),
                  const SizedBox(width: 12),
                  _actionButton(Icons.account_balance, 'Mortgage', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MortgageScreen()))),
                ]),
              ]),
            ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required Color color, required Widget child}) {
    return Card(
      color: color.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [Icon(icon, size: 28), const SizedBox(height: 8), Text(label)]),
          ),
        ),
      ),
    );
  }
}
