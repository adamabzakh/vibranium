class UserTime {
  final String title;
  final double totalTimeSeconds;
  final double usedTimeSeconds;

  UserTime({
    required this.title,
    required this.totalTimeSeconds,
    required this.usedTimeSeconds,
  });

  // Convert the object to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'totalTimeSeconds': totalTimeSeconds,
      'usedTimeSeconds': usedTimeSeconds,
    };
  }

  // Recommended: Add a fromJson factory for API responses
  factory UserTime.fromJson(Map<String, dynamic> json) {
    return UserTime(
      title: json['Name'] ?? '',
      totalTimeSeconds: (json['Seconds'] ?? 0).toDouble(),
      usedTimeSeconds: (json['SecondsUsed'] ?? 0).toDouble(),
    );
  }

  // Useful Helper: Get remaining time
  double get remainingTimeSeconds => totalTimeSeconds - usedTimeSeconds;
}
