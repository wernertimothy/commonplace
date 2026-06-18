import 'package:flutter/material.dart';

/// The header block shown atop the project & topic detail screens:
/// a large title, an optional description (with an edit/add affordance),
/// and a section label (e.g. "Topics" / "Notes") above the list below it.
class DetailHeader extends StatelessWidget {
  final String title;
  final String description;
  final String sectionLabel;
  final VoidCallback onEditDescription;

  const DetailHeader({
    super.key,
    required this.title,
    required this.description,
    required this.sectionLabel,
    required this.onEditDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription = description.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (hasDescription)
            GestureDetector(
              onTap: onEditDescription,
              child: Text(
                description,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            TextButton.icon(
              onPressed: onEditDescription,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add description'),
            ),
          const SizedBox(height: 24),
          Text(
            sectionLabel,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
