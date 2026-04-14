import 'package:app/core/theme/vibranium_theme.dart';
import 'package:app/models/tournament_entry.dart';
import 'package:flutter/material.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  static const _items = <TournamentEntry>[
    TournamentEntry(title: 'Vibranium Spring Clash', game: 'FC 24', dateText: 'Apr 4 · 8:00 PM', prize: '150 JOD', status: 'Upcoming', location: 'Main Stage', format: '1v1 Knockout', entryFee: '3.00 JOD', description: 'Fast-paced FC 24 bracket. One loss eliminates, final is best of 3.', schedule: ['Check-in: 7:15 PM', 'Bracket publish: 7:45 PM', 'Matches start: 8:00 PM', 'Final: 10:15 PM']),
    TournamentEntry(title: 'Night Ops Cup', game: 'Call of Duty', dateText: 'Apr 7 · 9:30 PM', prize: '300 JOD', status: 'Upcoming', location: 'VIP Arena', format: '5v5 Team Bracket', entryFee: '10.00 JOD / team', description: 'Tactical 5v5 tournament with single elimination and map veto before each round.', schedule: ['Check-in: 8:45 PM', 'Team seed: 9:10 PM', 'Round 1: 9:30 PM', 'Grand final: 11:30 PM']),
    TournamentEntry(title: 'Rocket Duo League', game: 'Rocket League', dateText: 'Live now', prize: '120 JOD', status: 'Live', location: 'Console Zone', format: '2v2 League Stage', entryFee: '2.50 JOD / player', description: 'Ongoing duo league. Top 4 teams from league stage qualify to playoff finals.', schedule: ['League day started: 6:30 PM', 'Current round: Matchday 3', 'Playoffs: 9:00 PM']),
    TournamentEntry(title: 'Winter Cup Finals', game: 'Valorant', dateText: 'Finished', prize: '500 JOD', status: 'Finished', location: 'Main Stage', format: '5v5 Finals', entryFee: 'Closed', description: 'Season finals completed. Brackets and match stats are available in archived details.', schedule: ['Final ended: Yesterday', 'MVP announced: Yesterday']),
  ];

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text('Compete. Win. Rank up.', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ..._items.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: VibraniumColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(t.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _statusColor(colorScheme, t.status).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)), child: Text(t.status, style: theme.textTheme.labelSmall?.copyWith(color: _statusColor(colorScheme, t.status), fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 8),
                  Text('${t.game} · ${t.dateText}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  Text('Prize pool: ${t.prize}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  Row(children: [
                    FilledButton(onPressed: t.status == 'Finished' ? null : () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registered for ${t.title}'))), child: const Text('Register')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => TournamentDetailsScreen(tournament: t))), child: const Text('Details')),
                  ]),
                ]),
              ),
            ),
          )),
        ],
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tournament.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(tournament.description, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                _DetailRow(label: 'Game', value: tournament.game),
                _DetailRow(label: 'Date', value: tournament.dateText),
                _DetailRow(label: 'Location', value: tournament.location),
                _DetailRow(label: 'Format', value: tournament.format),
                _DetailRow(label: 'Entry fee', value: tournament.entryFee),
                _DetailRow(label: 'Prize pool', value: tournament.prize),
              ]),
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
      child: Row(children: [
        SizedBox(width: 82, child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant))),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ]),
    );
  }
}
