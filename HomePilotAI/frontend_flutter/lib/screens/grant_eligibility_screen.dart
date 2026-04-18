import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grant_match_model.dart';
import '../services/ai_service.dart';
import '../widgets/empty_state.dart';

class GrantEligibilityScreen extends StatelessWidget {
  const GrantEligibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GrantMatchModel>>(
      future: context.read<AiService>().getGrants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EmptyState(snapshot.error.toString().replaceFirst('Exception: ', ''));
        }

        final grants = snapshot.data!;
        if (grants.isEmpty) {
          return const EmptyState('No grant matches found yet.');
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: grants.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final grant = grants[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(grant.programName, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text(grant.rationale),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: [
                        Chip(
                          label: Text('\$${grant.coverageAmount.toStringAsFixed(0)} coverage'),
                        ),
                        Chip(
                          label: Text('${grant.eligibilityScore.toStringAsFixed(0)} match'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
