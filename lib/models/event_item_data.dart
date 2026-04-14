import 'package:flutter/material.dart';

class EventItemData {
  const EventItemData({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String timeAgo;

  factory EventItemData.fromJson(Map<String, dynamic> m) {
    return EventItemData(
      icon: _iconForKey((m['icon'] as String?) ?? 'redeem'),
      accent: _colorFromHex((m['accentHex'] as String?) ?? '22D3EE'),
      title: (m['title'] as String?) ?? '',
      subtitle: (m['subtitle'] as String?) ?? '',
      timeAgo: (m['timeAgo'] as String?) ?? '',
    );
  }
}

IconData _iconForKey(String key) {
  switch (key) {
    case 'login':
      return Icons.login_rounded;
    case 'person_add':
      return Icons.person_add_alt_1_rounded;
    case 'wallet':
    case 'add_card':
      return Icons.add_card_rounded;
    case 'computer':
      return Icons.computer_rounded;
    case 'redeem':
    default:
      return Icons.redeem_rounded;
  }
}

Color _colorFromHex(String hex) {
  var h = hex.trim();
  if (h.startsWith('#')) h = h.substring(1);
  if (h.length == 6) {
    return Color(int.parse('FF$h', radix: 16));
  }
  if (h.length == 8) {
    return Color(int.parse(h, radix: 16));
  }
  return const Color(0xFF22D3EE);
}
