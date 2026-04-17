import 'package:app/core/theme/vibranium_theme.dart';
import 'package:app/models/tournament_entry.dart';
import 'package:flutter/material.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  static const _items = <TournamentEntry>[];

  Color _statusColor(ColorScheme scheme, String status) {
    switch (status) {
      case 'Live':
        return const Color(0xFFEF5350);
      case 'Upcoming':
        return scheme.tertiary;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (_items.isEmpty)
                ? Container()
                : Text(
                    'Compete. Win. Rank up.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
            const SizedBox(height: 12),

            (_items.isEmpty)
                ? Center(
                    child: const Text(
                      'No tournaments available.\nStay tuned!',
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      ..._items.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: VibraniumColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          t.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                            colorScheme,
                                            t.status,
                                          ).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          t.status,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: _statusColor(
                                                  colorScheme,
                                                  t.status,
                                                ),
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${t.game} · ${t.dateText}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    'Prize pool: ${t.prize}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      FilledButton(
                                        onPressed: t.status == 'Finished'
                                            ? null
                                            : () =>
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Registered for ${t.title}',
                                                      ),
                                                    ),
                                                  ),
                                        child: const Text('Register'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(context).push<void>(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    TournamentDetailsScreen(
                                                      tournament: t,
                                                    ),
                                              ),
                                            ),
                                        child: const Text('Details'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class TournamentDetailsScreen extends StatelessWidget {
  const TournamentDetailsScreen({super.key, required this.tournament});
  final TournamentEntry tournament;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tournament details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Material(
            color: VibraniumColors.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tournament.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Game', value: tournament.game),
                  _DetailRow(label: 'Date', value: tournament.dateText),
                  _DetailRow(label: 'Location', value: tournament.location),
                  _DetailRow(label: 'Format', value: tournament.format),
                  _DetailRow(label: 'Entry fee', value: tournament.entryFee),
                  _DetailRow(label: 'Prize pool', value: tournament.prize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
