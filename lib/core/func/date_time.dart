String formatLastSeen(DateTime pastDate) {
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(pastDate);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w ago';
  } else {
    // If it's very old, just show the date
    return '${pastDate.day}/${pastDate.month}/${pastDate.year}';
  }
}

String formatDuration(int totalSeconds) {
  if (totalSeconds < 0) return "0s";

  int hours = totalSeconds ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  if (hours > 0) {
    return "${hours}h ${minutes}m";
  } else if (minutes > 0) {
    return "${minutes}m ${seconds}s";
  } else {
    return "${seconds}s";
  }
}
