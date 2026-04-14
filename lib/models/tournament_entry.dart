class TournamentEntry {
  const TournamentEntry({
    required this.title,
    required this.game,
    required this.dateText,
    required this.prize,
    required this.status,
    required this.location,
    required this.format,
    required this.entryFee,
    required this.description,
    required this.schedule,
  });

  final String title;
  final String game;
  final String dateText;
  final String prize;
  final String status;
  final String location;
  final String format;
  final String entryFee;
  final String description;
  final List<String> schedule;

  factory TournamentEntry.fromJson(Map<String, dynamic> m) {
    final sched = m['schedule'];
    return TournamentEntry(
      title: (m['title'] as String?) ?? '',
      game: (m['game'] as String?) ?? '',
      dateText: (m['dateText'] as String?) ?? '',
      prize: (m['prize'] as String?) ?? '',
      status: (m['status'] as String?) ?? 'Upcoming',
      location: (m['location'] as String?) ?? '',
      format: (m['format'] as String?) ?? '',
      entryFee: (m['entryFee'] as String?) ?? '',
      description: (m['description'] as String?) ?? '',
      schedule: sched is List
          ? sched.map((e) => e.toString()).toList()
          : const <String>[],
    );
  }
}
