import 'package:app/core/func/date_time.dart';
import 'package:app/core/models/session.dart';
import 'package:app/core/theme/vibranium_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key, required this.sessions});

  final List<GgSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: VibraniumColors.black,
      appBar: AppBar(
        backgroundColor: VibraniumColors.black,
        surfaceTintColor: Colors.transparent,
        title: const Text('All events'),
      ),
      body: sessions.isEmpty
          ? Center(
              child: Text(
                'No Sessions yet.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final event = sessions[index];
                return Material(
                  color: VibraniumColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withAlpha(14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.computer,
                            color: theme.primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pc session",
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "From ${DateFormat("yyyy/mm/dd hh:mm").format(event.addedAt)} - to ${DateFormat("yyyy/mm/dd hh:mm").format(event.endDateTime!)}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatLastSeen(event.endDateTime!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
