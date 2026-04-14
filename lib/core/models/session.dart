class GgSession {
  final String uuid;
  final DateTime addedAt;
  final String name;
  final double used;
  final double total;

  GgSession({
    required this.uuid,
    required this.addedAt,
    required this.name,
    required this.used,
    required this.total,
  });

  // Factory to create a session from JSON
  factory GgSession.fromJson(Map<String, dynamic> json) {
    return GgSession(
      uuid: json['Uuid'],
      addedAt: DateTime.parse(json['AddedAt']),
      name: json['Name'],
      total: double.parse(json['Seconds'].toString()),
      used: double.parse(json['SecondsUsed'].toString()),
    );
  }

  // Helper: Get formatted duration (e.g., "1h 30m")
  String get formattedDuration {
    final duration = Duration(seconds: used.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }
    return "${minutes}m";
  }

  // Helper: Calculate end time based on start and duration
  DateTime? get endDateTime {
    return addedAt.add(Duration(seconds: used.toInt()));
  }
}
