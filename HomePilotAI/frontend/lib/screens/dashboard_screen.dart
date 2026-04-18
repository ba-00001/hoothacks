import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../widgets/metric_card.dart';
import '../widgets/listing_card.dart';
import 'login_screen.dart';
import 'listings_screen.dart';
import 'grants_screen.dart';
import 'mortgage_screen.dart';
import 'saved_screen.dart';
import 'profile_setup_screen.dart';
import 'chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _affordability;
  Map<String, dynamic>? _grants;
  Map<String, dynamic>? _recommendations;
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadDashboard(); }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId')!;
      final results = await Future.wait([
        api.getAffordability(userId),
        api.getGrants(userId),
        api.getRecommendations(userId),
        api.getProfile(userId),
      ]);
      setState(() {
        _affordability = results[0] as Map<String, dynamic>;
        _grants = results[1] as Map<String, dynamic>;
        _recommendations = results[2] as Map<String, dynamic>;
        _profile = results[3] as Map<String, dynamic>;
      });
    } catch (e) { debugPrint('Dashboard error: $e'); }
    finally { setState(() => _loading = false); }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    api.clearAuth();
    if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = _profile?['name'] ?? 'there';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Hey, $name', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(userId: prefs.getInt('userId')!)));
          }),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(_affordability?['summary'] ?? 'Update your profile to see insights', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  
                  // Dashboard Metrics
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 240,
                          child: MetricCard(
                            title: 'Recommended Rent',
                            value: '\$${_affordability?['recommendedRentMin'] ?? 0} - \$${_affordability?['recommendedRentMax'] ?? 0}',
                            caption: 'Best-fit monthly rent range',
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 240,
                          child: MetricCard(
                            title: 'Purchase Range',
                            value: 'Up to \$${_affordability?['recommendedPurchaseMax'] ?? 0}',
                            caption: 'Estimated home purchase max',
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 240,
                          child: MetricCard(
                            title: 'Debt-to-Income',
                            value: '${_affordability?['estimatedDTI'] ?? 'N/A'}',
                            caption: 'Estimated DTI Ratio',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick Actions Re-styled
                  Row(children: [
                    _actionTile(Icons.search_rounded, 'Listings', cs.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingsScreen()))),
                    const SizedBox(width: 10),
                    _actionTile(Icons.favorite_rounded, 'Saved', Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScreen()))),
                    const SizedBox(width: 10),
                    _actionTile(Icons.calculate_rounded, 'Mortgage', Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MortgageScreen()))),
                    const SizedBox(width: 10),
                    _actionTile(Icons.volunteer_activism_rounded, 'Grants', Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrantsScreen()))),
                  ]),
                  const SizedBox(height: 24),

                  Text('Top Listings For You', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  
                  if (_recommendations?['recommendations'] != null)
                    ...(_recommendations!['recommendations'] as List).take(3).map((r) => ListingCard(
                      title: r['title'],
                      location: r['location'],
                      priceLabel: (r['price'] is num && (r['price'] as num) > 10000) ? '\$${r['price']}' : '\$${r['price']}/mo',
                      details: '${r['bedrooms']} bd • ${r['bathrooms']} ba',
                      scoreLabel: '${(r['score'] * 100).round()}% match',
                    )),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
        icon: const Icon(Icons.smart_toy_rounded),
        label: const Text('Ask Advisor'),
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      ),
    );
  }
}