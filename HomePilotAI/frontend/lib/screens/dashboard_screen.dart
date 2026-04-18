import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: CustomScrollView(slivers: [
                // Modern SliverAppBar
                SliverAppBar(
                  expandedHeight: 140, floating: true, pinned: true,
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text('Hey, $name', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  ),
                  actions: [
                    IconButton(icon: const Icon(Icons.person_outline), onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(userId: prefs.getInt('userId')!)));
                    }),
                    IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    // Affordability
                    _glassCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Your Budget',
                      gradient: [cs.primary.withOpacity(0.15), cs.primary.withOpacity(0.05)],
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (_affordability?['recommendedRentMin'] != null) ...[
                          Text('Rent: \$${_affordability!['recommendedRentMin']}–\$${_affordability!['recommendedRentMax']}/mo',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.primary)),
                          const SizedBox(height: 4),
                          Text('Purchase max: ~\$${_affordability!['recommendedPurchaseMax']}',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        ] else
                          Text(_affordability?['summary'] ?? 'Complete your profile for analysis', style: const TextStyle(fontSize: 15)),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    // Quick Actions
                    Row(children: [
                      _actionTile(Icons.search_rounded, 'Listings', cs.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingsScreen()))),
                      const SizedBox(width: 10),
                      _actionTile(Icons.favorite_rounded, 'Saved', Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScreen()))),
                      const SizedBox(width: 10),
                      _actionTile(Icons.account_balance_rounded, 'Mortgage', Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MortgageScreen()))),
                      const SizedBox(width: 10),
                      _actionTile(Icons.card_giftcard_rounded, 'Grants', Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrantsScreen()))),
                    ]),
                    const SizedBox(height: 20),

                    // Grants
                    _glassCard(
                      icon: Icons.volunteer_activism_rounded,
                      title: 'Eligible Grants',
                      gradient: [Colors.teal.withOpacity(0.12), Colors.teal.withOpacity(0.03)],
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (_grants?['matchedGrants'] != null)
                          ...(_grants!['matchedGrants'] as List).take(2).map((g) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                child: Text('${(g['matchScore'] * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text('${g['programName']}', style: const TextStyle(fontSize: 14))),
                              Text('\$${g['coverageAmount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                          )),
                        Align(alignment: Alignment.centerRight, child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrantsScreen())),
                          child: const Text('View all →'),
                        )),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    // Recommendations
                    _glassCard(
                      icon: Icons.star_rounded,
                      title: 'Top Picks For You',
                      gradient: [Colors.amber.withOpacity(0.12), Colors.amber.withOpacity(0.03)],
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (_recommendations?['recommendations'] != null)
                          ...(_recommendations!['recommendations'] as List).take(3).map((r) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                            child: Row(children: [
                              Icon(r['price'] is num && (r['price'] as num) > 10000 ? Icons.house_rounded : Icons.apartment_rounded, color: cs.primary, size: 28),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(r['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                Text('\$${r['price']} • ${r['location']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ])),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text('${(r['score'] * 100).round()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.primary)),
                              ),
                            ]),
                          )),
                        Align(alignment: Alignment.centerRight, child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListingsScreen())),
                          child: const Text('Browse all →'),
                        )),
                      ]),
                    ),
                    const SizedBox(height: 80),
                  ])),
                ),
              ]),
            ),
      // Chatbot FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
        icon: const Icon(Icons.smart_toy_rounded),
        label: const Text('Ask Advisor'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _glassCard({required IconData icon, required String title, required List<Color> gradient, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _actionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
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
