import 'package:flutter/material.dart';

class FacilityTierModel {
  const FacilityTierModel({
    required this.label,
    required this.free,
    required this.total,
  });

  final String label;
  final int free;
  final int total;

  double get freeRatio => total <= 0 ? 0 : free / total;

  double get occupiedRatio => total <= 0 ? 0 : (total - free) / total;
}

class FacilitySectionModel {
  const FacilitySectionModel({
    required this.title,
    required this.icon,
    required this.accent,
    required this.tiers,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<FacilityTierModel> tiers;
}
