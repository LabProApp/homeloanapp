import 'package:flutter/material.dart';

class AmenityIcon {
  static IconData getIcon(String amenityNumber) {
    switch (amenityNumber) {
      case "1":
        return Icons.pool;
      case "2":
        return Icons.elevator;
      case "3":
        return Icons.fitness_center;
      case "4":
        return Icons.fitness_center;
      case "5":
        return Icons.security;
      case "6":
        return Icons.wifi;
      case "7":
        return Icons.groups;
      default:
        return Icons.check_circle_outline;
    }
  }
}
