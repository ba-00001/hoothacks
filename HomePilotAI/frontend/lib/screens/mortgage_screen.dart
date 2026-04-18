import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../widgets/metric_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mortgage Estimate'), backgroundColor: Colors.transparent),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Could not load estimate'))
              : ListView(padding: const EdgeInsets.all(20), children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: MetricCard(
                          title: 'Estimated Monthly Payment',
                          value: '\$${_data!['estimatedMonthlyPayment']}/mo',
                          caption: 'Conservative payment target',
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: MetricCard(
                          title: 'Purchase Price',
                          value: '\$${_data!['recommendedPurchasePrice']}',
                          caption: 'Suggested Max',
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: MetricCard(
                          title: 'Down Payment',
                          value: '\$${_data!['estimatedDownPayment']}',
                          caption: 'Target Amount',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Loan Details', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Interest Rate', style: TextStyle(fontSize: 16)),
                              Text('${_data!['interestRateUsed']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Loan Term', style: TextStyle(fontSize: 16)),
                              Text('${_data!['loanTermYears']} years', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Readiness Score', style: TextStyle(fontSize: 16)),
                              Text('${(_data!['readinessScore'] * 100).round()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
    );
  }
}