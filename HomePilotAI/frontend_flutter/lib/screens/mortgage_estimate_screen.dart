import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mortgage_estimate_model.dart';
import '../services/ai_service.dart';
import '../widgets/metric_card.dart';

class MortgageEstimateScreen extends StatefulWidget {
  const MortgageEstimateScreen({super.key});

  @override
  State<MortgageEstimateScreen> createState() => _MortgageEstimateScreenState();
}

class _MortgageEstimateScreenState extends State<MortgageEstimateScreen> {
  final _downPaymentController = TextEditingController();
  MortgageEstimateModel? _estimate;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEstimate();
  }

  @override
  void dispose() {
    _downPaymentController.dispose();
    super.dispose();
  }

  Future<void> _loadEstimate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final parsed = double.tryParse(_downPaymentController.text.trim());
      final estimate = await context.read<AiService>().getMortgageEstimate(
            downPayment: parsed,
          );
      if (!mounted) return;
      setState(() => _estimate = estimate);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _downPaymentController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Down payment (optional)',
            hintText: '10000',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _isLoading ? null : _loadEstimate,
          child: Text(_isLoading ? 'Calculating...' : 'Refresh estimate'),
        ),
        const SizedBox(height: 20),
        if (_error != null) Text(_error!),
        if (_estimate != null) ...[
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 230,
                child: MetricCard(
                  title: 'Estimated Budget',
                  value: '\$${_estimate!.estimatedBudget.toStringAsFixed(0)}',
                  caption: 'Estimated purchase budget',
                ),
              ),
              SizedBox(
                width: 230,
                child: MetricCard(
                  title: 'Monthly Payment',
                  value: '\$${_estimate!.monthlyPayment.toStringAsFixed(0)}',
                  caption: 'Conservative payment target',
                ),
              ),
              SizedBox(
                width: 230,
                child: MetricCard(
                  title: 'Readiness Score',
                  value: '${_estimate!.readinessScore}/100',
                  caption: 'Loan eligibility readiness',
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
                  Text(
                    'Suggested purchase range',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${_estimate!.recommendedPurchaseMin.toStringAsFixed(0)} - \$${_estimate!.recommendedPurchaseMax.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 12),
                  Text(_estimate!.summary),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
