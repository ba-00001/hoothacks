import 'package:flutter/material.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.title,
    required this.location,
    required this.priceLabel,
    required this.details,
    this.description,
    this.imageUrl,
    this.scoreLabel,
    this.summary,
    this.onSave,
  });

  final String title;
  final String location;
  final String priceLabel;
  final String details;
  final String? description;
  final String? imageUrl;
  final String? scoreLabel;
  final String? summary;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property photo
          _PropertyImage(imageUrl: imageUrl),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (scoreLabel != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F3EE),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          scoreLabel!,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      location,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  priceLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.bed_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(details,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (summary != null && summary!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    summary!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (onSave != null) ...[
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: onSave,
                    icon: const Icon(Icons.favorite_border_rounded, size: 16),
                    label: const Text('Save'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, st) => _Placeholder(),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                height: 180,
                color: const Color(0xFFEEEAE2),
                child: const Center(child: CircularProgressIndicator()),
              ),
      );
    }
    return _Placeholder();
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD6EDE8), Color(0xFFEAF0E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.home_work_rounded,
        size: 56,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}
