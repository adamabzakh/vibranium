class UnifiedPC {
  final String id;
  final String uuid;
  final double x;
  final double y;
  final String categoryId;
  final String areaId;
  final String displayName;
  final String state;
  final bool isOccupied;

  UnifiedPC({
    required this.id,
    required this.uuid,
    required this.x,
    required this.y,
    required this.categoryId,
    required this.areaId,
    required this.displayName,
    required this.state,
    required this.isOccupied,
  });
}
