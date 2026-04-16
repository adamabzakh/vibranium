class UserRank {
  final String uuid;
  final String rank;
  final String reward;
  String hasCollected;
  final List<dynamic> pastCollections;
  final double totalSpent;

  UserRank({
    required this.uuid,
    required this.rank,
    required this.reward,
    required this.hasCollected,
    required this.pastCollections,
    required this.totalSpent,
  });

  factory UserRank.fromJson(Map<String, dynamic> json) {
    return UserRank(
      uuid: json['uuid']?.toString() ?? '',
      rank: json['rank']?.toString() ?? 'Unranked',
      reward: json['reward']?.toString() ?? 'None',
      hasCollected: json['hasCollected']?.toString() ?? 'false',
      pastCollections: json['pastCollections'] is List
          ? List<dynamic>.from(json['pastCollections'])
          : [],
      totalSpent: double.tryParse(json['totalSpent'].toString()) ?? 0.0,
    );
  }
}
