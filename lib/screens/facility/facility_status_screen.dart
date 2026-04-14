import 'package:app/core/theme/vibranium_theme.dart';
import 'package:app/models/facility_models.dart';
import 'package:flutter/material.dart';

class FacilityStatusScreen extends StatelessWidget {
  const FacilityStatusScreen({super.key});

  static const _sections = <FacilitySectionModel>[
    FacilitySectionModel(title: 'PC', icon: Icons.computer_rounded, accent: Color(0xFF22D3EE), tiers: [
      FacilityTierModel(label: 'Normal', free: 8, total: 74),
      FacilityTierModel(label: 'Stage', free: 1, total: 10),
      FacilityTierModel(label: 'VIP', free: 2, total: 11),
      FacilityTierModel(label: 'Master VIP', free: 0, total: 6),
    ]),
    FacilitySectionModel(title: 'PlayStation', icon: Icons.sports_esports_rounded, accent: Color(0xFFA855F7), tiers: [
      FacilityTierModel(label: 'Normal', free: 3, total: 7),
      FacilityTierModel(label: 'VIP rooms', free: 1, total: 3),
      FacilityTierModel(label: 'Master VIP room', free: 0, total: 1),
    ]),
    FacilitySectionModel(title: 'Simulator', icon: Icons.directions_car_filled_rounded, accent: Color(0xFFFFB74D), tiers: [
      FacilityTierModel(label: 'Simulator', free: 1, total: 2),
    ]),
    FacilitySectionModel(title: 'Pool tables', icon: Icons.table_bar_rounded, accent: Color(0xFF81C784), tiers: [
      FacilityTierModel(label: 'Pool tables', free: 1, total: 5),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: VibraniumColors.black,
      appBar: AppBar(
        backgroundColor: VibraniumColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.of(context).maybePop()),
        title: Text('Venue status', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          final section = _sections[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index < _sections.length - 1 ? 24 : 0),
            child: _SectionBlock(section: section, theme: theme),
          );
        },
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section, required this.theme});
  final FacilitySectionModel section;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: section.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(section.icon, color: section.accent, size: 22)),
        const SizedBox(width: 12),
        Text(section.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3)),
      ]),
      const SizedBox(height: 12),
      ...section.tiers.map((tier) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _TierCard(tier: tier, accent: section.accent))),
    ]);
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, required this.accent});
  final FacilityTierModel tier;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final busy = tier.total - tier.free;
    return Material(
      color: VibraniumColors.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(tier.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
            Text('${tier.free} / ${tier.total} free', style: theme.textTheme.labelLarge?.copyWith(color: tier.free == 0 ? colorScheme.error : colorScheme.tertiary, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: tier.occupiedRatio, minHeight: 6, backgroundColor: colorScheme.outline.withValues(alpha: 0.35), color: accent)),
          const SizedBox(height: 8),
          Text(busy <= 0 ? 'All stations available' : '$busy in use · ${(tier.freeRatio * 100).round()}% free', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
