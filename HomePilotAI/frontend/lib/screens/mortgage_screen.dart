import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class MortgageScreen extends StatefulWidget {
  const MortgageScreen({super.key});
  @override
  State<MortgageScreen> createState() => _MortgageScreenState();
}

class _MortgageScreenState extends State<MortgageScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    try { _data = await api.getMortgageEstimate(prefs.getInt('userId')!); } catch (e) { debugPrint('$e'); }
    setState(() => _loading = false);
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 16)),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mortgage Estimate')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Could not load estimate'))
              : ListView(padding: const EdgeInsets.all(24), children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        const Icon(Icons.account_balance, size: 48),
                        const SizedBox(height: 12),
                        Text('\$${_data!['estimatedMonthlyPayment']}/mo',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text('Estimated Monthly Payment'),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        _row('Purchase Price', '\$${_data!['recommendedPurchasePrice']}'),
                        _row('Down Payment', '\$${_data!['estimatedDownPayment']}'),
                        _row('Interest Rate', '${_data!['interestRateUsed']}'),
                        _row('Loan Term', '${_data!['loanTermYears']} years'),
                        _row('Credit Estimate', '${_data!['creditEstimate']}'),
                        const Divider(),
                        _row('Readiness Score', '${(_data!['readinessScore'] * 100).round()}%'),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Source: ${_data?['source'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
    );
  }
}
