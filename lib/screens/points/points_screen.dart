import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/theme/vibranium_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Points & rewards')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VibraniumColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: colorScheme.tertiary,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available points',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      userProvider.user!.pointsBalance!.toStringAsFixed(0),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _RewardTile(title: '1 Hours', cost: 5000),
          const SizedBox(height: 10),
          _RewardTile(title: '2 Hours', cost: 9000),
          const SizedBox(height: 10),
          _RewardTile(title: '4 hours', cost: 15000),
          const SizedBox(height: 10),
          _RewardTile(title: '8 hours', cost: 24000),
          const SizedBox(height: 10),
          _RewardTile(title: 'Day Pass (12 hour)', cost: 32000),
          const SizedBox(height: 10),
          _RewardTile(title: 'All night pass (15 hour)', cost: 39000),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.title, required this.cost});
  final String title;
  final int cost;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VibraniumColors.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(title: Text(title), subtitle: Text('$cost pts')),
    );
  }
}
