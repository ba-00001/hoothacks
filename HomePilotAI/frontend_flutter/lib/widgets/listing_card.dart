import 'package:flutter/material.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.title,
    required this.location,
    required this.priceLabel,
    required this.details,
    this.scoreLabel,
    this.summary,
    this.onSave,
  });

  final String title;
  final String location;
  final String priceLabel;
  final String details;
  final String? scoreLabel;
  final String? summary;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (scoreLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F3EE),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(scoreLabel!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(location),
            const SizedBox(height: 6),
            Text(
              priceLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(details),
            if (summary != null && summary!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(summary!),
            ],
            if (onSave != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onSave,
                icon: const Icon(Icons.favorite_border_rounded),
                label: const Text('Save Property'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
