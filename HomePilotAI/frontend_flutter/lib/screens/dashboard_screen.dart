import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_model.dart';
import '../services/ai_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/listing_card.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardModel>(
      future: context.read<AiService>().getDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EmptyState(snapshot.error.toString().replaceFirst('Exception: ', ''));
        }

        final dashboard = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () => context.read<AiService>().getDashboard(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                dashboard.affordability.message,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 240,
                    child: MetricCard(
                      title: 'Recommended Rent',
                      value:
                          '\$${dashboard.affordability.recommendedRentMin.toStringAsFixed(0)} - \$${dashboard.affordability.recommendedRentMax.toStringAsFixed(0)}',
                      caption: 'Best-fit monthly rent range',
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: MetricCard(
                      title: 'Purchase Range',
                      value:
                          '\$${dashboard.affordability.recommendedPurchaseMin.toStringAsFixed(0)} - \$${dashboard.affordability.recommendedPurchaseMax.toStringAsFixed(0)}',
                      caption: 'Estimated home purchase range',
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: MetricCard(
                      title: 'Mortgage Readiness',
                      value: '${dashboard.mortgageEstimate.readinessScore}/100',
                      caption: 'Loan-readiness estimate',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Eligible Grants', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              if (dashboard.grants.isEmpty)
                const EmptyState('No grant matches yet. Update your profile to improve matching.')
              else
                ...dashboard.grants.take(3).map(
                      (grant) => Card(
                        child: ListTile(
                          title: Text(grant.programName),
                          subtitle: Text(grant.rationale),
                          trailing: Text(
                            '\$${grant.coverageAmount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              Text('Top Listings', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...dashboard.topListings.map(
                (listing) => ListingCard(
                  title: listing.title,
                  location: listing.location,
                  priceLabel: listing.rentOrBuy == 'RENT'
                      ? '\$${listing.price.toStringAsFixed(0)}/mo'
                      : '\$${listing.price.toStringAsFixed(0)}',
                  details: '${listing.bedrooms} bd • ${listing.bathrooms} ba',
                  scoreLabel: '${listing.score.toStringAsFixed(0)} match',
                  summary: listing.fitSummary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
